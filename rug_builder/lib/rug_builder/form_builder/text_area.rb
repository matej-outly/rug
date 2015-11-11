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

			# Localization
			if options[:localization].nil?
				localization = [nil]
				is_localized = false
			else
				localization = options[:localization]
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
				result += text_area(suffixed_name, field_options)
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

	end
end