# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - text area TODO
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
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
				klass = []
				klass << options[:class] if !options[:class].nil?
				if options[:tinymce] == false
					klass << "textarea input"
				elsif !options[:tinymce].nil?
					klass << options[:tinymce]
				else
					klass << "tinymce"
				end
				field_options[:class] = klass.join(" ")
				field_options[:id] = options[:id] if !options[:id].nil?

				# Localization
				if options[:localization].nil? || options[:localization] == false
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
#	end
end