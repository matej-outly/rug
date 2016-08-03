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

			def dropzone_row(name, options = {})
				
				update_url = self.options[:update_url] || options[:update_url]
				create_url = self.options[:create_url] || options[:create_url]
				if !update_url || (object.new_record? && !create_url)
					raise "Please define update and create URL in form or row options."
				end

				# Preset
				result = ""

				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label])
					end
				else
					result += label(name)
				end

				# Default URL and method
				default_url = (object.new_record? ? RugSupport::PathResolver.new(@template).resolve(create_url) : RugSupport::PathResolver.new(@template).resolve(update_url, object))
				default_method = (object.new_record? ? "post" : "put")

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Java Script
				js = ""
				js += "function dropzone_#{hash}_ready()\n"
				js += "{\n"
				js += "	Dropzone.autoDiscover = false;\n"
				js += "	var dropzone = new Dropzone('div##{object.class.model_name.param_key}_#{name.to_s}', {\n"
				js += "		url: '#{default_url}',\n"
				js += "		method: '#{default_method}', /* method given by function not working, that's why we do it by changing static options in success event */\n"
				js += "		paramName: '#{object.class.model_name.param_key}[#{name.to_s}]',\n"
				js += "		maxFiles: 1,\n"
				js += "		dictDefaultMessage: '#{I18n.t("general.drop_file_here")}',\n"
				js += "	});\n"
				js += "	dropzone.on('sending', function(file, xhr, data) {\n"
				js += "		data.append('authenticity_token', '#{@template.form_authenticity_token}');\n"
				if options[:append_columns]
					options[:append_columns].each do |append_column, as_column|
						as_column = append_column if as_column == true
						js += "		data.append('#{object.class.model_name.param_key}[#{as_column}]', $('##{object.class.model_name.param_key}_#{append_column.to_s}').val());\n"
					end
				end
				js += "	});\n"
				js += "	dropzone.on('maxfilesexceeded', function(file) {\n"
				js += "		this.options.maxFiles = 1;\n"
				js += "		this.removeAllFiles(true);\n"
				js += "		this.addFile(file);\n"
				js += "	});\n"
				js += "	dropzone.on('success', function(file, response) {\n"
				js += "		var response_id = parseInt(response);\n"
				js += "		if (!isNaN(response_id)) {\n"
				js += "			var form = $('##{self.options[:html][:id]}');\n"
				js += "			var update_url = '#{RugSupport::PathResolver.new(@template).resolve(update_url, ":id")}'.replace(':id', response_id);\n"
				js += "			if (form.attr('action') != update_url) {\n"
				js += "				form.attr('action', update_url); /* Form */\n"
				js += "				form.prepend('<input type=\\'hidden\\' name=\\'_method\\' value=\\'patch\\' />');\n"
				js += "			}\n"
				js += "			this.options.url = update_url; /* Dropzone - this causes that only one dropzone is supported for creating */\n"
				js += "			this.options.method = 'put';\n"
				if options[:crop] == true
					crop_hash = Digest::SHA1.hexdigest(name.to_s)
					js += "			crop_#{crop_hash}_reload(response_id);\n"
				end
				js += "		} else { /* Error saving image */ \n"
				js += "		}\n"
				js += "	});\n"

				value = object.send(name)
				if value && value.exists?
					js += "	var mock_file = { name: '#{object.send(name.to_s + "_file_name")}', size: #{object.send(name.to_s + "_file_size")} };\n"
					js += "	dropzone.emit('addedfile', mock_file);\n"
					js += "	dropzone.emit('thumbnail', mock_file, '#{value.url}');\n"
					js += "	dropzone.files.push(mock_file);\n"
					js += "	dropzone.emit('complete', mock_file);\n"
					js += "	dropzone.options.maxFiles = dropzone.options.maxFiles - 1;\n"
				end

				js += "}\n"
				js += "$(document).ready(dropzone_#{hash}_ready);\n"

				# Dropzone
				result += @template.javascript_tag(js)
				result += "<div class=\"form-group\">"
				result += "<div id=\"#{object.class.model_name.param_key}_#{name.to_s}\" class=\"dropzone\"><div class=\"dz-message\">#{I18n.t("general.drop_file_here")}</div></div>"
				result += "</div>"

				return result.html_safe
			end

			def dropzone_many_row(name, attachment_name, create_url, destroy_url, collection = nil, collection_class = nil, options = {})
				
				# Collection
				if collection.nil?
					collection = object.send(name)
				end
				if collection.nil?
					raise "Please define collection."
				end

				# Collection model class
				if collection_class.nil?
					collection_class = object.class.reflect_on_association(name).class_name.constantize
				end

				# Preset
				result = ""

				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label])
					end
				else
					result += label(name)
				end

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Java Script
				js = ""
				js += "function dropzone_many_#{hash}_add_file(dropzone, file_name, file_size, thumb_url, record_id)\n"
				js += "{\n"
				js += "	var mock_file = { name: file_name, size: file_size, record_id: record_id };\n"
				js += "	dropzone.emit('addedfile', mock_file);\n"
				js += "	dropzone.emit('thumbnail', mock_file, thumb_url);\n"
				js += "	dropzone.files.push(mock_file);\n"
				js += "	dropzone.emit('complete', mock_file);\n"
				js += "}\n"
				js += "function dropzone_many_#{hash}_ready()\n"
				js += "{\n"
				js += "	Dropzone.autoDiscover = false;\n"
				js += "	var dropzone = new Dropzone('div##{object.class.model_name.param_key}_#{name.to_s}', {\n"
				js += "		url: '#{RugSupport::PathResolver.new(@template).resolve(create_url)}',\n"
				js += "		method: 'post',\n"
				js += "		paramName: '#{collection_class.model_name.param_key}[#{attachment_name}]',\n"
				js += "		addRemoveLinks: true,\n"
				js += "		dictDefaultMessage: '#{I18n.t("general.drop_file_here")}',\n"
				js += "		dictRemoveFile: '#{I18n.t("general.action.destroy")}',\n"
				js += "		dictCancelUpload: '#{I18n.t("general.action.cancel")}',\n"
				js += "		dictCancelUploadConfirmation: '#{I18n.t("general.are_you_sure")}',\n"
				js += "	});\n"
				js += "	dropzone.on('sending', function(file, xhr, data) {\n"
				js += "		data.append('authenticity_token', '#{@template.form_authenticity_token}');\n"
				if options[:append_columns]
					options[:append_columns].each do |append_column, as_column|
						as_column = append_column if as_column == true
						js += "		data.append('#{collection_class.model_name.param_key}[#{as_column}]', $('##{object.class.model_name.param_key}_#{append_column.to_s}').val());\n"
					end
				end
				js += "	});\n"
				js += "	dropzone.on('success', function(file, response) {\n"
				js += "		var response_id = parseInt(response);\n"
				js += "		if (!isNaN(response_id)) {\n"
				js += "			file.record_id = response_id;\n"
				js += "		} else { /* Error saving image */\n"
				js += "		}\n"
				js += "	});\n"
				js += "	dropzone.on('removedfile', function(file) {\n"
				js += "		if (file.record_id) {\n"
				js += "			var destroy_url = '#{RugSupport::PathResolver.new(@template).resolve(destroy_url, ":id")}'.replace(':id', file.record_id);\n"
				js += "			$.ajax({\n"
				js += "				url: destroy_url,\n"
				js += "				dataType: 'json',\n"
				js += "				type: 'DELETE'\n"
				js += "			});\n"
				js += "		}\n"
				js += "	});\n"
				
				collection.each do |item|
					value = item.send(attachment_name)
					if value && value.exists?
						js += "	dropzone_many_#{hash}_add_file(dropzone, '#{item.send(attachment_name.to_s + "_file_name")}', #{item.send(attachment_name.to_s + "_file_size")}, '#{value.url}', #{item.id});\n"
					end
				end

				js += "}\n"
				js += "$(document).ready(dropzone_many_#{hash}_ready);\n"

				# Dropzone
				result += @template.javascript_tag(js)
				result += "<div class=\"form-group\">"
				result += "<div id=\"#{object.class.model_name.param_key}_#{name.to_s}\" class=\"dropzone\"></div>"
				result += "</div>"

				return result.html_safe
			end
			
		end
#	end
end