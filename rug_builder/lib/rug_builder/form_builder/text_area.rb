# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - text area
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder

		def text_area_row(name, options = {})
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
			field_options[:class] = "tinymce"
			field_options[:id] = options[:id] if !options[:id].nil?

			# Field
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			result += text_area(name, field_options)
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