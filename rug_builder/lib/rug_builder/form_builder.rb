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
			result = "<p>"
			
			# Label
			if !options.nil? && !options[:label].nil?
				result += label(name, options[:label])
			else
				result += label(name)
			end

			# Field
			result += "<div class=\"field\"><textarea class=\"input textarea\" disabled=\"disabled\">"
			result += content
			result += "</textarea></div>"
			
			result += "</p>"
			return result.html_safe
		end

		def text_input_row(name, method, options = nil)
			result = "<p>"
			
			# Label
			if !options.nil? && !options[:label].nil?
				result += label(name, options[:label])
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

			result += "</p>"
			return result.html_safe
		end

		def text_area_row(name, options = nil)
			result = "<p>"
			
			# Label
			if !options.nil? && !options[:label].nil?
				result += label(name, options[:label])
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

			result += "</p>"
			return result.html_safe
		end

		def picker_row(name, collection = nil, value_attr = :value, label_attr = :label, options = nil)
			result = "<p>"
			
			# Label
			if !options.nil? && !options[:label].nil?
				result += label(name, options[:label])
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
			result += "</p>"
			return result.html_safe
		end

		def radios_row(name, collection = nil, value_attr = :value, label_attr = :label, options = nil)
			result = "<p>"
			
			# Label
			if !options.nil? && !options[:label].nil?
				result += label(name, options[:label])
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

			result += "</p>"
			return result.html_safe
		end

		def checkboxes_row(name, collection = nil, value_attr = :value, label_attr = :label, options = nil)
			result = "<p>"
			
			# Label
			if !options.nil? && !options[:label].nil?
				result += label(name, options[:label])
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

			result += "</p>"
			return result.html_safe
		end

		def checkbox_row(name, options = nil)
			result = "<p>"
			
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

			result += "</p>"
			return result.html_safe
		end

		def address_row(name, options = nil)
			result = "<p>"
			
			# Label
			if !options.nil? && !options[:label].nil?
				result += label(name, options[:label])
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

			result += "</p>"
			return result.html_safe
		end

		def datepicker_row(name, options = nil)
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# JavaScript
			js = ""
			js += "function datepicker_#{hash}_ready()"
			js += "{"
			js += "	$('#datepicker_#{hash}').pikaday({ "
			js += "		firstDay: 1,"
			js += "		format: 'YYYY-MM-DD',"
			js += "		i18n: {"
			js += "			previousMonth : 'Předchozí měsíc',"
			js += "			nextMonth     : 'Následující měsíc',"
			js += "			months        : ['Leden','Únor','Březen','Duben','Květen','Červen','Červenec','Srpen','Září','Říjen','Listopad','Prosinec'],"
			js += "			weekdays      : ['Neděle','Pondělí','Úterý','Středa','Čtvrtek','Pátek','Sobota'],"
			js += "			weekdaysShort : ['Ne','Po','Út','St','Čt','Pá','So']"
			js += "		}"
			js += "	});"
			js += "}"
			js += "$(document).ready(datepicker_#{hash}_ready);"
			js += "$(document).on('page:load', datepicker_#{hash}_ready);"
			
			# CSS
			css = ""
			css += ".pika-single table thead { background: none; }"
			css += ".pika-single table thead th, .pika-single table tbody td { border: 0; }"
			css += ".is-selected .pika-button { background: #33aaff; border-radius: 0; }"
			css += ".pika-button:hover { background: #616161 !important; border-radius: 0 !important; }"

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
				result += label(name, options[:label])
			else
				result += label(name)
			end

			# Default URL and method
			default_url = (object.new_record? ? resolve_path(self.options[:create_url]) : resolve_path(self.options[:update_url], object))
			default_method = (object.new_record? ? "post" : "put")

			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			js = ""
			js += "function dropzone_#{hash}_ready()"
			js += "{"
			js += "	Dropzone.autoDiscover = false;"
			js += "	var dropzone = new Dropzone('div##{object.class.model_name.param_key}_#{name.to_s}', {"
			js += "		url: '#{default_url}',"
			js += "		method: '#{default_method}', /* method given by function not working, that's why we do it by changing static options in success event */"
			js += "		paramName: '#{object.class.model_name.param_key}[#{name.to_s}]',"
			js += "		maxFiles: 1"
			js += "	});"
			js += "	dropzone.on('sending', function(file, xhr, data) {"
			js += "		data.append('authenticity_token', '#{@template.form_authenticity_token}');"
			if options[:append_columns]
				options[:append_columns].each do |append_column|
					js += "		data.append('#{object.class.model_name.param_key}[#{append_column}]', $('##{object.class.model_name.param_key}_#{append_column.to_s}').val());"
				end
			end
			js += "	});"
			js += "	dropzone.on('maxfilesexceeded', function(file) {"
			js += "		this.options.maxFiles = 1;"
			js += "		this.removeAllFiles(true);"
			js += "		this.addFile(file);"
			js += "	});"
			js += "	dropzone.on('success', function(file, response) {"
			js += "		var response_id = parseInt(response);"
			js += "		if (!isNaN(response_id)) {"
			js += "			var form = $('##{self.options[:html][:id]}');"
			js += "			var update_url = '#{resolve_path(self.options[:update_url], ":id")}'.replace(':id', response_id);"
			js += "			if (form.attr('action') != update_url) {"
			js += "				form.attr('action', update_url); /* Form */"
			js += "				form.prepend('<input type=\\'hidden\\' name=\\'_method\\' value=\\'patch\\' />');"
			js += "			}"
			js += "			this.options.url = update_url; /* Dropzone - this causes that only one dropzone is supported for creating */"
			js += "			this.options.method = 'put';"
			js += "		} else { /* Error saving image */ "
			js += "		}"
			js += "	});"

			value = object.send(name)
			if value && value.exists?
				js += "	var mock_file = { name: '#{object.send(name.to_s + "_file_name")}', size: #{object.send(name.to_s + "_file_size")} };"
				js += "	dropzone.emit('addedfile', mock_file);"
				js += "	dropzone.emit('thumbnail', mock_file, '#{value.url}');"
				js += "	dropzone.files.push(mock_file);"
				js += "	dropzone.emit('complete', mock_file);"
				js += "	dropzone.options.maxFiles = dropzone.options.maxFiles - 1;"
			end

			js += "}"
			js += "$(document).ready(dropzone_#{hash}_ready);"
			js += "$(document).on('page:load', dropzone_#{hash}_ready);"

			# Dropzone
			result += @template.javascript_tag(js)
			result += "<div id=\"#{object.class.model_name.param_key}_#{name.to_s}\" class=\"dropzone\"><div class=\"dz-message\">#{I18n.t("general.drop_file_here")}</div></div>"

			return result.html_safe
		end

		def primary_button_row(method, options = nil)
			if !options.nil? && !options[:label].nil?
				return "<p><div class=\"medium primary btn\">#{self.method(method).call(options[:label])}</div></p>".html_safe
			else
				return "<p><div class=\"medium primary btn\">#{self.method(method).call}</div></p>".html_safe
			end
		end

		def conditional_section(section_name, condition_name, condition_rule, &block)
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(section_name.to_s)

			# JavaScript
			js = ""
			js += "var conditional_section_#{hash}_ready_in_progress = true;"
			
			js += "function conditional_section_#{hash}_interpret(value) {"
			js += "		console.log(value);"
			js += "		if (" + condition_rule + ") {"
			js += "			if (conditional_section_#{hash}_ready_in_progress) {"
			js += "				$('#conditional_section_#{hash}').show();"
			js += "			} else {"
			js += "				$('#conditional_section_#{hash}').slideDown();"
			js += "			}"
			js += "		} else {"
			js += "			if (conditional_section_#{hash}_ready_in_progress) {"
			js += "				$('#conditional_section_#{hash}').hide();"
			js += "			} else {"
			js += "				$('#conditional_section_#{hash}').slideUp();"
			js += "			}"
			js += "		}"
			js += "		conditional_section_#{hash}_ready_in_progress = false;"
			js += "}"

			js += "function conditional_section_#{hash}_ready() {"
			js += "	"
			js += "	$('#conditional_section_#{hash}').hide();"
			js += "	$('[name=\\'#{object.class.model_name.param_key}[#{condition_name.to_s}]\\']').on('change', function(e) {"
			js += "		var _this = $(this);"
			js += "		if (_this.is(':radio')) {"
			js += "			if (_this.is(':checked')) {"
			js += "				conditional_section_#{hash}_interpret(_this.val());"
			js += "			}"
			js += "		} else {"
			js += "			conditional_section_#{hash}_interpret(_this.val());"
			js += "		}"
			js += "	}).trigger('change');"
			js += "}"
			js += "$(document).ready(conditional_section_#{hash}_ready);"
			js += "$(document).on('page:load', conditional_section_#{hash}_ready);"
			
			# Section
			result = ""
			result += @template.javascript_tag(js)
			result += @template.content_tag(:div, { :id => "conditional_section_#{hash}" }, &block)
			
			return result.html_safe
		end

	end
end
