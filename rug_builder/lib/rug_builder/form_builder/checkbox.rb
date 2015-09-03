# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - checkbox
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder

		def checkboxes_row(name, collection = nil, value_attr = :value, label_attr = :label, options = {})
			result = "<div class=\"element\">"
			
			# Label
			if !options[:label].nil?
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

		def checkbox_row(name, options = {})
			result = "<div class=\"element\">"
			
			# Field
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			if !options[:label].nil?
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

	end
end