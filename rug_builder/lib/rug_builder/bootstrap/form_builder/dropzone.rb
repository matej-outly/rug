# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - dropzone
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Dropzone element to upload single file as attribute of model
			#
			# Options:
			# - create_url (string of lamba function)
			# - update_url (string of lamba function)
			# - crop (string) ... JS object implementing reload() function
			#
			def dropzone_row(name, options = {})
				result = ""

				# URLs
				update_url = self.options[:update_url] || options[:update_url]
				create_url = self.options[:create_url] || options[:create_url]
				if !update_url || (object.new_record? && !create_url)
					raise "Please define update and create URL in form or row options."
				end
				
				# Default URL and method
				default_url = (object.new_record? ? RugSupport::PathResolver.new(@template).resolve(create_url) : RugSupport::PathResolver.new(@template).resolve(update_url, object))
				default_method = (object.new_record? ? "post" : "put")

				# Crop
				crop = (options[:crop] ? options[:crop] : nil)

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Label
				result += compose_label(name, options)

				# Library JS code
				result += @template.javascript_tag(%{
					function RugFormDropzone(hash, options)
					{
						this.hash = hash;
						this.dropzone = null;
						this.options = (typeof options !== 'undefined' ? options : {});
					}
					RugFormDropzone.prototype = {
						constructor: RugFormDropzone,
						addFile: function(fileName, fileSize, thumbUrl)
						{
							var mockFile = { name: fileName, size: fileSize };
							this.dropzone.emit('addedfile', mockFile);
							this.dropzone.emit('thumbnail', mockFile, thumbUrl);
							this.dropzone.files.push(mockFile);
							this.dropzone.emit('complete', mockFile);
							this.dropzone.options.maxFiles = this.dropzone.options.maxFiles - 1;
						},
						ready: function()
						{
							var _this = this;

							// Dropzone	
							Dropzone.autoDiscover = false;
							this.dropzone = new Dropzone('div#' + this.options.objectParamKey + '_' + this.options.name, {
								url: this.options.defaultUrl,
								method: this.options.defaultMethod, /* method given by function not working, that's why we do it by changing static options in success event */
								paramName: this.options.objectParamKey + '[' + this.options.name + ']',
								maxFiles: 1,
								dictDefaultMessage: this.options.defaultMessage,
							});

							// Events
							this.dropzone.on('sending', function(file, xhr, data) {
								data.append('authenticity_token', _this.options.formAuthenticityToken);
								if (_this.options.appendColumns) {
									for (appendColumn in _this.options.appendColumns) {
										var asColumn = _this.options.appendColumns[appendColumn];
										data.append(_this.options.objectParamKey + '[' + asColumn + ']', $('#' + _this.options.objectParamKey + '_' + appendColumn).val());
									}
								}
							});
							this.dropzone.on('maxfilesexceeded', function(file) {
								this.options.maxFiles = 1;
								this.removeAllFiles(true);
								this.addFile(file);
							});
							this.dropzone.on('success', function(file, response) {
								var responseId = parseInt(response);
								if (!isNaN(responseId)) {
									var form = $(_this.options.formSelector);
									var updateUrl = _this.options.updateUrl.replace(':id', responseId);
									if (form.attr('action') != updateUrl) {
										form.attr('action', updateUrl); /* Form */
										form.prepend('<input type="hidden" name="_method" value="patch" />');
									}
									this.options.url = updateUrl; /* Dropzone - this causes that only one dropzone is supported for creating */
									this.options.method = 'put';
									if (_this.options.crop) {
										eval('var crop = ' + _this.options.crop + ';');
										crop.reload(responseId);
									}
								} else { /* Error saving image */ 
								}
							});

						}
					}
				})

				# Append columns
				append_columns_js = "{"
				if options[:append_columns]
					options[:append_columns].each do |append_column, as_column|
						as_column = append_column if as_column == true
						append_columns_js += "#{append_column}: '#{as_column}',"
					end
				end
				append_columns_js += "}"

				# Default file
				defaut_file_js = ""
				value = object.send(name)
				if value && value.exists?
					defaut_file_js = "rug_form_dropzone_#{hash}.addFile('#{object.send(name.to_s + "_file_name")}', #{object.send(name.to_s + "_file_size")}, '#{value.url}');\n"
				end

				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_dropzone_#{hash} = null;
					$(document).ready(function() {
						rug_form_dropzone_#{hash} = new RugFormDropzone('#{hash}', {

							// Columns names
							name: '#{name}',
							
							// Param keys
							objectParamKey: '#{object.class.model_name.param_key}',

							// URLs
							defaultUrl: '#{default_url}',
							defaultMethod: '#{default_method}',
							updateUrl: '#{RugSupport::PathResolver.new(@template).resolve(update_url, ":id")}',
							
							// Form
							formSelector: '##{self.options[:html][:id]}',
							formAuthenticityToken: '#{@template.form_authenticity_token}',

							// Messages
							defaultMessage: '#{I18n.t("general.drop_file_here")}',

							// Options
							appendColumns: #{append_columns_js},
							crop: '#{crop.to_s}',
						});
						rug_form_dropzone_#{hash}.ready();
						#{defaut_file_js}
					});
				})

				# HTML
				result += "<div class=\"form-group\">"
				result += "<div id=\"#{object.class.model_name.param_key}_#{name.to_s}\" class=\"dropzone\"><div class=\"dz-message\">#{I18n.t("general.drop_file_here")}</div></div>"
				result += "</div>"

				return result.html_safe
			end

			#
			# Dropzone element for uploading multiple files as nested collection
			#
			# Options:
			# - attachment_name (string)
			# - create_url (string of lamba function)
			# - destroy_url (string of lamba function)
			# - show_url (string of lamba function)
			# - collection
			# - collection_class
			# - move_to (string) ... JS object implementing addItem() function
			#
			def dropzone_many_row(name, options = {})
				result = ""

				# Attachment name
				attachment_name = options[:attachment_name]
				if attachment_name.nil?
					raise "Please define attachment name."
				end

				# Collection
				if options[:collection].nil?
					collection = object.send(name)
				else
					collection = options[:collection]
				end
				if collection.nil?
					raise "Please define collection."
				end

				# Collection model class
				if options[:collection_class].nil?
					collection_class = object.class.reflect_on_association(name).class_name.constantize
				else
					collection_class = options[:collection_class]
				end
				if collection_class.nil?
					raise "Please define collection class."
				end

				# URLs
				show_url = options[:show_url]
				create_url = options[:create_url]
				destroy_url = options[:destroy_url]
				if create_url.nil?
					raise "Please define create URL."
				end
				if options[:move_to] && show_url.nil?
					raise "Please define show URL."
				end
				if !options[:move_to] && destroy_url.nil?
					raise "Please define destroy URL."
				end

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Label
				result += compose_label(name, options)
				
				# Library JS code
				result += @template.javascript_tag(%{
					function RugDropzoneMany(hash, options)
					{
						this.hash = hash;
						this.dropzone = null;
						this.options = (typeof options !== 'undefined' ? options : {});
					}
					RugDropzoneMany.prototype = {
						constructor: RugDropzoneMany,
						addFile: function(fileName, fileSize, thumbUrl, recordId)
						{
							var mockFile = { name: fileName, size: fileSize, record_id: recordId };
							this.dropzone.emit('addedfile', mockFile);
							this.dropzone.emit('thumbnail', mockFile, thumbUrl);
							this.dropzone.files.push(mockFile);
							this.dropzone.emit('complete', mockFile);
						},
						ready: function()
						{
							var _this = this;
							
							// Dropzone init
							Dropzone.autoDiscover = false;
							this.dropzone = new Dropzone('div#' + this.options.objectParamKey + '_' + this.options.name, {
								url: this.options.createUrl,
								method: 'post',
								paramName: this.options.collectionParamKey + '[' + this.options.attachmentName + ']',
								addRemoveLinks: true,
								dictDefaultMessage: this.options.defaultMessage,
								dictRemoveFile: this.options.removeFileMessage,
								dictCancelUpload: this.options.cancelUploadMessage,
								dictCancelUploadConfirmation: this.options.cancelUploadConfirmationMessage,
							});

							// Events
							this.dropzone.on('sending', function(file, xhr, data) {
								data.append('authenticity_token', _this.options.formAuthenticityToken);
								if (_this.options.appendColumns) {
									for (appendColumn in _this.options.appendColumns) {
										var asColumn = _this.options.appendColumns[appendColumn];
										data.append(_this.options.collectionParamKey + '[' + asColumn + ']', $('#' + _this.options.objectParamKey + '_' + appendColumn).val());
									}
								}
							});
							this.dropzone.on('success', function(file, response) {
								var responseId = parseInt(response);
								if (!isNaN(responseId)) {
									file.record_id = responseId;
									if (_this.options.moveTo) {
										var showUrl = _this.options.showUrl.replace(':id', file.record_id);
										$.get(showUrl, function(data) {
											_this.dropzone.removeFile(file);
											_this.options.moveTo.forEach(function(item) {
												eval('var moveTo = ' + item + ';');
												moveTo.addItem(data);
											});
										});
									}
								} else { /* Error saving image */
								}
							});
							if (!this.options.moveTo) {
								this.dropzone.on('removedfile', function(file) {
									if (file.record_id) {
										var destroyUrl = _this.options.destroyUrl.replace(':id', file.record_id);
										$.ajax({
											url: destroyUrl,
											dataType: 'json',
											type: 'DELETE'
										});
									}
								});
							}
							
						}
					}
				})

				# Append columns
				append_columns_js = "{"
				if options[:append_columns]
					options[:append_columns].each do |append_column, as_column|
						as_column = append_column if as_column == true
						append_columns_js += "#{append_column}: '#{as_column}',"
					end
				end
				append_columns_js += "}"

				# Move to
				if options[:move_to] 
					move_to = options[:move_to]
					move_to = [move_to] if !move_to.is_a?(Array)
					move_to_js = "[" + move_to.map { |item| "'#{item}'" }.join(",") + "]"
				else
					move_to_js = "[]"
				end

				# Default files
				defaut_files_js = ""
				collection.each do |item|
					value = item.send(attachment_name)
					if value && value.exists?
						defaut_files_js += "rug_dropzone_many_#{hash}.addFile('#{item.send(attachment_name.to_s + "_file_name")}', #{item.send(attachment_name.to_s + "_file_size")}, '#{value.url}', #{item.id});\n"
					end
				end

				# Application JS code
				result += @template.javascript_tag(%{
					var rug_dropzone_many_#{hash} = null;
					$(document).ready(function() {
						rug_dropzone_many_#{hash} = new RugDropzoneMany('#{hash}', {

							// Columns names
							name: '#{name}',
							attachmentName: '#{attachment_name}',
							
							// Param keys
							collectionParamKey: '#{collection_class.model_name.param_key}',
							objectParamKey: '#{object.class.model_name.param_key}',

							// URLs
							createUrl: '#{RugSupport::PathResolver.new(@template).resolve(create_url)}',
							destroyUrl: '#{RugSupport::PathResolver.new(@template).resolve(destroy_url, ":id")}',
							showUrl: '#{RugSupport::PathResolver.new(@template).resolve(show_url, ":id")}',
							
							// Form
							formAuthenticityToken: '#{@template.form_authenticity_token}',

							// Messages
							defaultMessage: '#{I18n.t("general.drop_file_here")}',
							removeFileMessage: '#{I18n.t("general.action.destroy")}',
							cancelUploadMessage: '#{I18n.t("general.action.cancel")}',
							cancelUploadConfirmationMessage: '#{I18n.t("general.are_you_sure")}',

							// Options
							appendColumns: #{append_columns_js},
							moveTo: #{move_to_js},
						});
						rug_dropzone_many_#{hash}.ready();
						#{move_to.nil? && defaut_files_js}
					});
				})

				# HTML
				result += "<div class=\"form-group\">"
				result += "<div id=\"#{object.class.model_name.param_key}_#{name.to_s}\" class=\"dropzone\"></div>"
				result += "</div>"

				return result.html_safe
			end
			
		end
#	end
end