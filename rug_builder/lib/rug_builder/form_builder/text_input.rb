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

		def text_input_row(name, method, options = {})
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
			field_options[:class] = "text input"
			field_options[:id] = options[:id] if !options[:id].nil?
			
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

		def text_input_many_row(name, method, options = {})
			result = "<div class=\"element\">"
			
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
			js += "	field.find('.core input').val(JSON.stringify(values));\n"
			js += "}\n"
			js += "function text_input_many_#{hash}_update_front()\n"
			js += "{\n"
			js += "	var field = $('#text_input_many_#{hash}').closest('.field');\n"
			js += "	var values = JSON.parse(field.find('.core input').val());\n"
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
			front_field_options[:class] = "text input"

			# Value
			value = object.send(name)
			value = value.to_json if value

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

	end
end