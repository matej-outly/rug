# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - text input
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder

		def text_input_row(name, method = :text_field, options = {})
			result = "<div class=\"element\">"
			
			# Label
			if !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Field options
			field_options = {}
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input"
			field_options[:class] = klass.join(" ")
			field_options[:id] = options[:id] if !options[:id].nil?
			field_options[:value] = options[:value] if !options[:value].nil?
			field_options[:placeholder] = options[:placeholder] if !options[:placeholder].nil?
			field_options[:min] = options[:min] if !options[:min].nil?
			field_options[:max] = options[:max] if !options[:max].nil?
			
			# Localization
			if options[:localization].nil?
				localization = [nil]
				is_localized = false
			else
				if options[:localization].is_a?(Array)
					localization = options[:localization]
				else
					localization = I18n.available_locales
				end
				is_localized = true
			end

			# Tab header
			if is_localized
				result += "<section class=\"tabs pill minimal\">"
				result += "<ul class=\"tab-nav\">"
				localization.each_with_index do |locale, index|
					result += "<li class=\"#{(index == 0 ? "active" : "")}\"><a href=\"#\">#{locale.to_s.upcase}</a></li>"
				end
				result += "</ul>"
			end

			localization.each_with_index do |locale, index|
				
				# Tab content
				if is_localized
					result += "<div class=\"tab-content #{(index == 0 ? "active" : "")}\">"
					suffixed_name = (name.to_s + "_#{locale.to_s}").to_sym
				else
					suffixed_name = name
				end

				# Field
				result += "<div class=\"field #{( object.errors[suffixed_name].size > 0 ? "danger" : "")}\">"
				result += self.method(method).call(suffixed_name, field_options)
				result += "</div>"
				
				# Errors
				if object.errors[suffixed_name].size > 0
					result += @template.content_tag(:span, object.errors[suffixed_name][0], :class => "danger label")
				end

				# Tab content
				if is_localized
					result += "</div>"
				end

			end

			if is_localized
				result += "</section>"
			end

			result += "</div>"
			return result.html_safe
		end

		def text_input_many_row(name, method = :text_field, options = {})
			result = "<div class=\"element\">"
			
			# Label
			if !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Format
			format = :json
			if !options[:format].nil?
				if options[:format].to_sym == :comma
					format = :comma
				end
			end

			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# Java Script
			js = ""
			js += "function text_input_many_#{hash}_update_core()\n"
			js += "{\n"
			js += "	var field = $('#text_input_many_#{hash}').closest('.field');\n"
			js += "	var values = [];\n"
			js += "	field.find('.front .field-item input').each(function() {\n"
			js += "		var value = $(this).val();\n"
			js += "		if (value) {\n"
			js += "			values.push(value);\n"
			js += "		}\n"
			js += "	});\n"
			if format == :comma
				js += "	field.find('.core input').val(values.join(','));\n"
			else
				js += "	field.find('.core input').val(JSON.stringify(values));\n"
			end
			js += "}\n"
			js += "function text_input_many_#{hash}_update_front()\n"
			js += "{\n"
			js += "	var field = $('#text_input_many_#{hash}').closest('.field');\n"
			if format == :comma
				js += "	var values = field.find('.core input').val().split(',');\n"
			else
				js += "	var values = JSON.parse(field.find('.core input').val());\n"
			end
			js += "	if (values instanceof Array) {\n"
			js += "		for (var idx = 0; idx < values.length; ++idx) {\n"
			js += "			text_input_many_#{hash}_add_front(values[idx]);\n"
			js += "		}\n"
			js += "	}\n"
			js += "}\n"
			js += "function text_input_many_#{hash}_add_front(value)\n"
			js += "{\n"
			js += "	var field = $('#text_input_many_#{hash}').closest('.field');\n"
			js += "	var front = field.find('.front');\n"
			js += "	var items_count = front.find('.field-item').length;\n"
			js += "	var new_item = $('<div class=\\'field-item\\'>' + field.find('.template').html() + '</div>');\n"
			js += "	new_item.find('input').val(value);\n"
			js += "	new_item.on('change', text_input_many_#{hash}_update_core);\n"
			js += "	front.append(new_item);\n"
			js += "	field.find('.controls .remove').show();\n"
			js += "}\n"
			js += "function text_input_many_#{hash}_remove_front()\n"
			js += "{\n"
			js += "	var field = $('#text_input_many_#{hash}').closest('.field');\n"
			js += "	var front = field.find('.front');\n"
			js += "	var items_count = front.find('.field-item').length;\n"
			js += "	front.find('.field-item').last().remove();\n"
			js += "	if (items_count <= 2) {\n"
			js += "		field.find('.controls .remove').hide();\n"
			js += "	}\n"
			js += "	text_input_many_#{hash}_update_core();\n"
			js += "}\n"
			js += "function text_input_many_#{hash}_ready()\n"
			js += "{\n"
			js += "	var field = $('#text_input_many_#{hash}').closest('.field');\n"
			js += "	field.find('.front .field-item input').on('change', text_input_many_#{hash}_update_core);\n"
			js += "	field.find('.controls .add').on('click', function(e) {\n"
			js += "		e.preventDefault();\n"
			js += "		text_input_many_#{hash}_add_front('');\n"
			js += "	});\n"
			js += "	field.find('.controls .remove').on('click', function(e) {\n"
			js += "		e.preventDefault();\n"
			js += "		text_input_many_#{hash}_remove_front();\n"
			js += "	});\n"
			js += "	text_input_many_#{hash}_update_front();\n"
			js += "}\n"
			js += "$(document).ready(text_input_many_#{hash}_ready);\n"
			js += "$(document).on('page:load', text_input_many_#{hash}_ready);\n"

			# Core field options
			core_field_options = {}
			core_field_options[:id] = "text_input_many_" + hash
			
			# Front field options
			front_field_options = {}
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input"
			field_options[:class] = klass.join(" ")

			# Value
			value = object.send(name)
			if value
				if format == :comma
					value = value.join(",")
				else
					value = value.to_json 
				end
			end

			# Field
			result += @template.javascript_tag(js)
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			result += "<div class=\"core\">" + @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value, core_field_options) + "</div>"
			result += "<div class=\"template\" style=\"display: none;\">" + @template.method("#{method.to_s}_tag").call(name, "", front_field_options) + "</div>"
			result += "<div class=\"front\"></div>"
			result += "<div class=\"controls\">" + @template.link_to("<i class=\"icon-plus\"></i>".html_safe + I18n.t("general.action.add"), "#", class: "add") + " " + @template.link_to("<i class=\"icon-cancel\"></i>".html_safe + I18n.t("general.action.remove"), "#", class: "remove") + "</div>"
			result += "</div>"
			
			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def address_row(name, options = {})
			result = "<div class=\"element\">"
			
			# Label
			if !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Part labels
			label_street = (options[:label_street] ? options[:label_street] : I18n.t("general.attribute.address.street"))
			label_number = (options[:label_number] ? options[:label_number] : I18n.t("general.attribute.address.number"))
			label_city = (options[:label_city] ? options[:label_city] : I18n.t("general.attribute.address.city"))
			label_postcode = (options[:label_postcode] ? options[:label_postcode] : I18n.t("general.attribute.address.postcode"))
			
			# Part values
			value = object.send(name)
			value_street = value && value[:street] ? value[:street] : nil
			value_number = value && value[:number] ? value[:number] : nil
			value_city = value && value[:city] ? value[:city] : nil
			value_postcode = value && value[:postcode] ? value[:postcode] : nil

			# Field options
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input"
			
			# Container
			result += "<div class=\"prepend field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Inputs (first row)
			result += "<div class=\"row\">"
			result += "<div class=\"eight columns field-item\">"
			result += "<span class=\"adjoined\">#{label_street.upcase_first}</span>" if options[:join] != false
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][street]", value_street, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_street.upcase_first : nil))
			result += "</div>"
			
			result += "<div class=\"four columns field-item\">"
			result += "<span class=\"adjoined\">#{label_number.upcase_first}</span>" if options[:join] != false
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][number]", value_number, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_number.upcase_first : nil))
			result += "</div>"
			result += "</div>"

			# Inputs (second row)
			result += "<div class=\"row\">"
			result += "<div class=\"eight columns field-item\">"
			result += "<span class=\"adjoined\">#{label_city.upcase_first}</span>" if options[:join] != false
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][city]", value_city, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_city.upcase_first : nil))
			result += "</div>"
			
			result += "<div class=\"four columns field-item\">"
			result += "<span class=\"adjoined\">#{label_postcode.upcase_first}</span>" if options[:join] != false
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][postcode]", value_postcode, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_postcode.upcase_first : nil))
			result += "</div>"
			result += "</div>"

			result += "</div>"

			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def name_row(name, options = {})
			result = "<div class=\"element\">"
			
			# Label
			if !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Part labels
			label_title = (options[:label_title] ? options[:label_title] : I18n.t("general.attribute.name.title")) if options[:title] == true
			label_firstname = (options[:label_firstname] ? options[:label_firstname] : I18n.t("general.attribute.name.firstname"))
			label_lastname = (options[:label_lastname] ? options[:label_lastname] : I18n.t("general.attribute.name.lastname"))
			
			# Part values
			value = object.send(name)
			value_title = value && value[:title] ? value[:title] : nil if options[:title] == true
			value_firstname = value && value[:firstname] ? value[:firstname] : nil
			value_lastname = value && value[:lastname] ? value[:lastname] : nil
			
			# Field options
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input"

			# Container
			result += "<div class=\"prepend field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Layout
			if options[:title] == true
				columns_layout = ["two", "five", "five"]
			else
				columns_layout = [nil, "six", "six"]
			end

			# Inputs
			result += "<div class=\"row\">"
			if options[:title] == true
				result += "<div class=\"#{columns_layout[0]} columns field-item\">"
				result += "<span class=\"adjoined\">#{label_title.upcase_first}</span>" if options[:join] != false
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][title]", value_title, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_title.upcase_first : nil))
				result += "</div>"
			end
			
			result += "<div class=\"#{columns_layout[1]} columns field-item\">"
			result += "<span class=\"adjoined\">#{label_firstname.upcase_first}</span>" if options[:join] != false
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][firstname]", value_firstname, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_firstname.upcase_first : nil))
			result += "</div>"
			
			result += "<div class=\"#{columns_layout[2]} columns field-item\">"
			result += "<span class=\"adjoined\">#{label_lastname.upcase_first}</span>" if options[:join] != false
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][lastname]", value_lastname, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_lastname.upcase_first : nil))
			result += "</div>"
			result += "</div>"

			# Container end
			result += "</div>"

			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def range_row(name, method = :number_field, options = {})
			result = "<div class=\"element\">"
			
			# Label
			if !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Part labels
			label_min = (options[:label_min] ? options[:label_min] : I18n.t("general.attribute.range.min"))
			label_max = (options[:label_max] ? options[:label_max] : I18n.t("general.attribute.range.max"))
			
			# Part values
			value = object.send(name)
			value_min = value && value[:min] ? value[:min] : nil
			value_max = value && value[:max] ? value[:max] : nil
			
			# Field options
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input"
			
			# Container
			result += "<div class=\"prepend field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Inputs
			result += "<div class=\"row\">"
			result += "<div class=\"six columns field-item\">"
			result += "<span class=\"adjoined\">#{label_min.upcase_first}</span>" if options[:join] != false
			result += @template.method("#{method.to_s}_tag").call("#{object.class.model_name.param_key}[#{name.to_s}][min]", value_min, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_min.upcase_first : nil))
			result += "</div>"
			
			result += "<div class=\"six columns field-item\">"
			result += "<span class=\"adjoined\">#{label_max.upcase_first}</span>" if options[:join] != false
			result += @template.method("#{method.to_s}_tag").call("#{object.class.model_name.param_key}[#{name.to_s}][max]", value_max, class: klass.dup.concat([(options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_max.upcase_first : nil))
			result += "</div>"
			result += "</div>"

			# Container end
			result += "</div>"

			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

	end
end