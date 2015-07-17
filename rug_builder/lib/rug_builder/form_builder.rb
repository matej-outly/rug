# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

require 'action_view'

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder
		
		def self.resolve_path(template, path, object = nil)
			if path.is_a?(Proc)
				if object.nil?
					return path.call
				else
					return path.call(object)
				end
			else
				if object.nil?
					return template.method(path.to_sym).call
				else
					return template.method(path.to_sym).call(object)
				end
			end
		end

		def resolve_path(path, object = nil)
			return self.class.resolve_path(@template, path, object)
		end

		def read_only_row(name, content, options = nil)
			result = "<div class=\"element\">"
			
			# Label
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Field
			result += "<div class=\"field\"><textarea class=\"input textarea\" disabled=\"disabled\">"
			result += content
			result += "</textarea></div>"
			
			result += "</div>"
			return result.html_safe
		end

		def text_input_row(name, method, options = nil)
			result = "<div class=\"element\">"
			
			# Label
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Field options
			field_options = {}
			field_options[:class] = "text input"
			field_options[:id] = options[:id] if !options.nil? && !options[:id].nil?
			
			# Field
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			result += self.method(method).call(name, field_options)
			result += "</div>"
			
			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def text_area_row(name, options = nil)
			result = "<div class=\"element\">"
			
			# Label
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Field
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			result += text_area(name, class: "tinymce")
			result += "</div>"
			
			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def picker_row(name, collection = nil, value_attr = :value, label_attr = :label, options = nil)
			result = "<div class=\"element\">"
			
			# Label
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Collection
			if collection.nil?
				collection = object.class.method("available_#{name.to_s.pluralize}".to_sym).call
			end

			# Enable null option
			if !options.nil? && options[:enable_null] == true
				collection = [OpenStruct.new({value_attr => nil, label_attr => I18n.t("general.null_option")})].concat(collection)
			end

			# Field
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			result += "<div class=\"picker\">"
			result += collection_select(name, collection, value_attr, label_attr)
			result += "</div>"
			result += "</div>"
			
			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end
			result += "</div>"
			return result.html_safe
		end

		def radios_row(name, collection = nil, value_attr = :value, label_attr = :label, options = nil)
			result = "<div class=\"element\">"
			
			# Label
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Collection
			if collection.nil?
				collection = object.class.method("available_#{name.to_s.pluralize}".to_sym).call
			end

			# Enable null option
			if !options.nil? && options[:enable_null] == true
				collection = [OpenStruct.new({value_attr => nil, label_attr => I18n.t("general.null_option")})].concat(collection)
			end

			# Disable Gumby (i.e. for working change event)
			if !options.nil? && options[:disable_gumby] == true
				disable_gumby = true
			else
				disable_gumby = false
			end

			# Field
			if disable_gumby
				result += "<div class=\"#{( object.errors[name].size > 0 ? "danger" : "")}\">"
			else
				result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			end
			result += collection_radio_buttons(name, collection, value_attr, label_attr) do |b|
				b.label(class: (disable_gumby ? "" : "radio")) do
					b.radio_button + "<span></span>&nbsp;&nbsp;#{b.text}".html_safe
				end
			end
			result += "</div>"
			
			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def checkboxes_row(name, collection = nil, value_attr = :value, label_attr = :label, options = nil)
			result = "<div class=\"element\">"
			
			# Label
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Field
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			if collection.nil?
				collection = object.class.method("available_#{name.to_s.pluralize}".to_sym).call
			end
			result += collection_check_boxes(name, collection, value_attr, label_attr) do |b|
				b.label(class: "checkbox") do
					b.check_box + "<span></span>&nbsp;&nbsp;#{b.text}".html_safe
				end
			end

			# Errors
			result += "</div>"
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def checkbox_row(name, options = nil)
			result = "<div class=\"element\">"
			
			# Field
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			if !options.nil? && !options[:label].nil?
				result += label(name, class: "checkbox") do
					check_box(name) + "<span></span>&nbsp;&nbsp;#{options[:label]}".html_safe
				end
			else
				result += label(name, class: "checkbox") do
					check_box(name) + "<span></span>&nbsp;&nbsp;#{object.class.human_attribute_name(name)}".html_safe
				end
			end
			result += "</div>"
			
			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def address_row(name, options = nil)
			result = "<div class=\"element\">"
			
			# Label
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Part labels
			label_street = ((!options.nil? && options[:label_street]) ? options[:label_street] : I18n.t("general.attribute.address.street"))
			label_number = ((!options.nil? && options[:label_number]) ? options[:label_number] : I18n.t("general.attribute.address.number"))
			label_city = ((!options.nil? && options[:label_city]) ? options[:label_city] : I18n.t("general.attribute.address.city"))
			label_postcode = ((!options.nil? && options[:label_postcode]) ? options[:label_postcode] : I18n.t("general.attribute.address.postcode"))
			
			# Part values
			value = object.send(name)
			value_street = value && value["street"] ? value["street"] : nil
			value_number = value && value["number"] ? value["number"] : nil
			value_city = value && value["city"] ? value["city"] : nil
			value_postcode = value && value["postcode"] ? value["postcode"] : nil

			# Field (first row)
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][street]", value_street, class: "text input xwide", placeholder: label_street)
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][number]", value_number, class: "text input xnarrow", placeholder: label_number)
			result += "</div>"

			# Field (second row)
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][city]", value_city, class: "text input xwide", placeholder: label_city)
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][postcode]", value_postcode, class: "text input xnarrow", placeholder: label_postcode)
			result += "</div>"

			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def datepicker_row(name, options = nil)
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# JavaScript
			js = ""
			js += "function datepicker_#{hash}_ready()\n"
			js += "{\n"
			js += "	$('#datepicker_#{hash}').pikaday({ \n"
			js += "		firstDay: 1,\n"
			js += "		format: 'YYYY-MM-DD',\n"
			js += "		i18n: {\n"
			js += "			previousMonth : '#{I18n.t("views.calendar.prev_month")}',\n"
			js += "			nextMonth     : '#{I18n.t("views.calendar.next_month")}',\n"
			js += "			months        : ['#{I18n.t("views.calendar.months.january")}','#{I18n.t("views.calendar.months.february")}','#{I18n.t("views.calendar.months.march")}','#{I18n.t("views.calendar.months.april")}','#{I18n.t("views.calendar.months.may")}','#{I18n.t("views.calendar.months.june")}','#{I18n.t("views.calendar.months.july")}','#{I18n.t("views.calendar.months.august")}','#{I18n.t("views.calendar.months.september")}','#{I18n.t("views.calendar.months.october")}','#{I18n.t("views.calendar.months.november")}','#{I18n.t("views.calendar.months.december")}'],\n"
			js += "			weekdays      : ['#{I18n.t("views.calendar.days.sunday")}','#{I18n.t("views.calendar.days.monday")}','#{I18n.t("views.calendar.days.tuesday")}','#{I18n.t("views.calendar.days.wednesday")}','#{I18n.t("views.calendar.days.thursday")}','#{I18n.t("views.calendar.days.friday")}','#{I18n.t("views.calendar.days.saturday")}'],\n"
			js += "			weekdaysShort : ['#{I18n.t("views.calendar.short_days.sunday")}','#{I18n.t("views.calendar.short_days.monday")}','#{I18n.t("views.calendar.short_days.tuesday")}','#{I18n.t("views.calendar.short_days.wednesday")}','#{I18n.t("views.calendar.short_days.thursday")}','#{I18n.t("views.calendar.short_days.friday")}','#{I18n.t("views.calendar.short_days.saturday")}']\n"
			js += "		}\n"
			js += "	});\n"
			js += "}\n"
			js += "$(document).ready(datepicker_#{hash}_ready);\n"
			js += "$(document).on('page:load', datepicker_#{hash}_ready);\n"
			
			# CSS
			css = ""
			css += ".pika-single table thead { background: none; }\n"
			css += ".pika-single table thead th, .pika-single table tbody td { border: 0; }\n"
			css += ".is-selected .pika-button { background: #33aaff; border-radius: 0; }\n"
			css += ".pika-button:hover { background: #616161 !important; border-radius: 0 !important; }\n"

			# Options
			options = {} if options.nil?
			options[:id] = "datepicker_#{hash}"

			# Datepicker
			result = ""
			result += @template.javascript_tag(js)
			result += "<style>" + css + "</style>"
			result += text_input_row(name, :text_field, options)

			return result.html_safe
		end

		def dropzone_row(name, options = nil)
			
			if !self.options[:update_url] || (object.new_record? && !self.options[:create_url])
				raise "Please define update and create URL."
			end

			# Preset
			result = ""

			# Label
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Default URL and method
			default_url = (object.new_record? ? resolve_path(self.options[:create_url]) : resolve_path(self.options[:update_url], object))
			default_method = (object.new_record? ? "post" : "put")

			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

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
			if !options.nil? && options[:append_columns]
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
			js += "			var update_url = '#{resolve_path(self.options[:update_url], ":id")}'.replace(':id', response_id);\n"
			js += "			if (form.attr('action') != update_url) {\n"
			js += "				form.attr('action', update_url); /* Form */\n"
			js += "				form.prepend('<input type=\\'hidden\\' name=\\'_method\\' value=\\'patch\\' />');\n"
			js += "			}\n"
			js += "			this.options.url = update_url; /* Dropzone - this causes that only one dropzone is supported for creating */\n"
			js += "			this.options.method = 'put';\n"
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
			js += "$(document).on('page:load', dropzone_#{hash}_ready);\n"

			# Dropzone
			result += @template.javascript_tag(js)
			result += "<div class=\"field\">"
			result += "<div id=\"#{object.class.model_name.param_key}_#{name.to_s}\" class=\"dropzone\"><div class=\"dz-message\">#{I18n.t("general.drop_file_here")}</div></div>"
			result += "</div>"

			return result.html_safe
		end

		def dropzone_many_row(name, attachment_name, create_url, destroy_url, collection = nil, collection_class = nil, options = nil)
			
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
			if !options.nil? && !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

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
			js += "		url: '#{resolve_path(create_url)}',\n"
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
			if !options.nil? && options[:append_columns]
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
			js += "			var destroy_url = '#{resolve_path(destroy_url, ":id")}'.replace(':id', file.record_id);\n"
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
			js += "$(document).on('page:load', dropzone_many_#{hash}_ready);\n"

			# Dropzone
			result += @template.javascript_tag(js)
			result += "<div class=\"field\">"
			result += "<div id=\"#{object.class.model_name.param_key}_#{name.to_s}\" class=\"dropzone\"></div>"
			result += "</div>"

			return result.html_safe
		end

		def primary_button_row(method, options = nil)
			if !options.nil? && !options[:label].nil?
				return "<div class=\"element\"><div class=\"medium primary btn\">#{self.method(method).call(options[:label])}</div></div>".html_safe
			else
				return "<div class=\"element\"><div class=\"medium primary btn\">#{self.method(method).call}</div></div>".html_safe
			end
		end

		def conditional_section(section_name, condition_name, condition_rule, &block)
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(section_name.to_s)

			# JavaScript
			js = ""
			js += "var conditional_section_#{hash}_ready_in_progress = true;\n"
			
			js += "function conditional_section_#{hash}_interpret(value)\n"
			js += "{\n"
			js += "		console.log(value);\n"
			js += "		if (" + condition_rule + ") {\n"
			js += "			if (conditional_section_#{hash}_ready_in_progress) {\n"
			js += "				$('#conditional_section_#{hash}').show();\n"
			js += "			} else {\n"
			js += "				$('#conditional_section_#{hash}').slideDown();\n"
			js += "			}\n"
			js += "		} else {\n"
			js += "			if (conditional_section_#{hash}_ready_in_progress) {\n"
			js += "				$('#conditional_section_#{hash}').hide();\n"
			js += "			} else {\n"
			js += "				$('#conditional_section_#{hash}').slideUp();\n"
			js += "			}\n"
			js += "		}\n"
			js += "		conditional_section_#{hash}_ready_in_progress = false;\n"
			js += "}\n"

			js += "function conditional_section_#{hash}_ready()\n"
			js += "{\n"
			js += "	$('#conditional_section_#{hash}').hide();\n"
			js += "	$('[name=\\'#{object.class.model_name.param_key}[#{condition_name.to_s}]\\']').on('change', function(e) {\n"
			js += "		var _this = $(this);\n"
			js += "		if (_this.is(':radio')) {\n"
			js += "			if (_this.is(':checked')) {\n"
			js += "				conditional_section_#{hash}_interpret(_this.val());\n"
			js += "			}\n"
			js += "		} else {\n"
			js += "			conditional_section_#{hash}_interpret(_this.val());\n"
			js += "		}\n"
			js += "	}).trigger('change');\n"
			js += "}\n"
			js += "$(document).ready(conditional_section_#{hash}_ready);\n"
			js += "$(document).on('page:load', conditional_section_#{hash}_ready);\n"
			
			# Section
			result = ""
			result += @template.javascript_tag(js)
			result += @template.content_tag(:div, { :id => "conditional_section_#{hash}" }, &block)
			
			return result.html_safe
		end

	end
end
