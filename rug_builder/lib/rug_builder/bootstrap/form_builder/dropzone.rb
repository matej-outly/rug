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
			# - notify_to_object (string) ... JS object implementing reload() function
			#                            which will be notified when file is uploaded
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

				# Notifi object
				notify_to_object = (options[:notify_to_object] ? options[:notify_to_object] : nil)

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end
				
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
							notifyToObject: '#{notify_to_object.to_s}',
						});
						rug_form_dropzone_#{hash}.ready();
						#{defaut_file_js}
					});
				})

				# HTML
				result += %{
					<div class="#{options[:form_group] != false ? "form-group" : ""}">
						#{label_for(name, label: options[:label])}
						<div id="#{object.class.model_name.param_key}_#{name.to_s}" class="dropzone">
							<div class="dz-message">#{I18n.t("general.drop_file_here")}</div>
						</div>
					</div>
				}

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
			# - move_to_object (string) ... JS object implementing addItem() function
			#                               where uploaded file will be moved
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
				if options[:move_to_object] && show_url.nil?
					raise "Please define show URL."
				end
				if !options[:move_to_object] && destroy_url.nil?
					raise "Please define destroy URL."
				end

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Append columns
				append_columns_js = "{"
				if options[:append_columns]
					options[:append_columns].each do |append_column, as_column|
						as_column = append_column if as_column == true
						append_columns_js += "#{append_column}: '#{as_column}',"
					end
				end
				append_columns_js += "}"

				# Move to object...
				if options[:move_to_object] 
					move_to_object = options[:move_to_object]
					move_to_object = [move_to_object] if !move_to_object.is_a?(Array)
					move_to_object_js = "[" + move_to_object.map { |item| "'#{item}'" }.join(",") + "]"
				else
					move_to_object_js = "[]"
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
							moveToObject: #{move_to_object_js},
						});
						rug_dropzone_many_#{hash}.ready();
						#{move_to_object.nil? && defaut_files_js}
					});
				})

				# HTML
				result += %{
					<div class="#{options[:form_group] != false ? "form-group" : ""}">
						#{label_for(name, label: options[:label])}
						<div id="#{object.class.model_name.param_key}_#{name.to_s}" class="dropzone"></div>
					</div>
				}

				return result.html_safe
			end
			
		end
#	end
end