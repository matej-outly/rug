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
			# - create_path (string or lamba function)
			# - update_path (string or lamba function)
			# - append_columns (hash)
			# - reload_object (string) ... JS object implementing reload() function
			#                              which will be called with new image src 
			#                              when file is uploaded.
			#
			def dropzone_row(name, options = {})
				result = ""

				# URLs
				update_path = self.options[:update_path] || options[:update_path]
				create_path = self.options[:create_path] || options[:create_path]
				if !update_path || (object.new_record? && !create_path)
					raise "Please define update and create URL in form or row options."
				end
				
				# Default URL and method
				default_url = (object.new_record? ? RugSupport::PathResolver.new(@template).resolve(create_path) : RugSupport::PathResolver.new(@template).resolve(update_path, object))
				default_method = (object.new_record? ? "post" : "put")

				# Reload object
				reload_object = (options[:reload_object] ? options[:reload_object] : nil)

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID (must be unique for each object of same type in case we render more edit forms on one page)
				id = object_name.to_s + (object.id ? "_" + object.id.to_s : "") + "_" + name.to_s
				
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

							// Column identification
							id: '#{id}',
							name: '#{name}',
							objectParamKey: '#{object.class.model_name.param_key}',

							// URLs
							defaultUrl: '#{default_url}',
							defaultMethod: '#{default_method}',
							updateUrl: '#{RugSupport::PathResolver.new(@template).resolve(update_path, ":id")}',
							
							// Form
							formSelector: '##{self.options[:html][:id]}',
							formAuthenticityToken: '#{@template.form_authenticity_token}',

							// Messages
							defaultMessage: '#{I18n.t("general.drop_file_here")}',

							// Options
							appendColumns: #{append_columns_js},
							reloadObject: '#{reload_object.to_s}',
						});
						rug_form_dropzone_#{hash}.ready();
						#{defaut_file_js}
					});
				})

				# HTML
				result += %{
					<div class="#{options[:form_group] != false ? "form-group" : ""}">
						#{label_for(name, label: options[:label])}
						<div id="#{id}" class="dropzone">
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
			# - create_path (string or lamba function)
			# - destroy_path (string or lamba function)
			# - collection
			# - collection_class
			# - append_columns (hash)
			# - reload_object (string or array) ... JS object implementing reload() function
			#                                       which is called when file is uploaded
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
				create_path = options[:create_path]
				destroy_path = options[:destroy_path]
				if create_path.nil?
					raise "Please define create URL."
				end
				if !options[:reload_object] && destroy_path.nil?
					raise "Please define destroy URL."
				end

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID (must be unique for each object of same type in case we render more edit forms on one page)
				id = object_name.to_s + (object.id ? "_" + object.id.to_s : "") + "_" + name.to_s

				# Append columns
				append_columns_js = "{"
				if options[:append_columns]
					options[:append_columns].each do |append_column, as_column|
						as_column = append_column if as_column == true
						append_columns_js += "#{append_column}: '#{as_column}',"
					end
				end
				append_columns_js += "}"

				# Reload object...
				if options[:reload_object] 
					reload_object = options[:reload_object]
					reload_object = [reload_object] if !reload_object.is_a?(Array)
					reload_object_js = "[" + reload_object.map { |item| "'#{item}'" }.join(",") + "]"
				else
					reload_object_js = "[]"
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

							// Column identification
							id: '#{id}',
							name: '#{name}',
							attachmentName: '#{attachment_name}',
							
							// Param keys
							collectionParamKey: '#{collection_class.model_name.param_key}',
							objectParamKey: '#{object.class.model_name.param_key}',

							// URLs
							createUrl: '#{RugSupport::PathResolver.new(@template).resolve(create_path)}',
							destroyUrl: '#{RugSupport::PathResolver.new(@template).resolve(destroy_path, ":id")}',
							
							// Form
							formAuthenticityToken: '#{@template.form_authenticity_token}',

							// Messages
							defaultMessage: '#{I18n.t("general.drop_file_here")}',
							removeFileMessage: '#{I18n.t("general.action.destroy")}',
							cancelUploadMessage: '#{I18n.t("general.action.cancel")}',
							cancelUploadConfirmationMessage: '#{I18n.t("general.are_you_sure")}',

							// Options
							appendColumns: #{append_columns_js},
							reloadObjects: #{reload_object_js},
						});
						rug_dropzone_many_#{hash}.ready();
						#{reload_object.nil? && defaut_files_js}
					});
				})

				# HTML
				result += %{
					<div class="#{options[:form_group] != false ? "form-group" : ""}">
						#{label_for(name, label: options[:label])}
						<div id="#{id}" class="dropzone">
							<div class="dz-message">#{I18n.t("general.drop_file_here")}</div>
						</div>
					</div>
				}

				return result.html_safe
			end
			
		end
#	end
end