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
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def text_area_row(name, options = {})
				result = ""
				
				# Label
				result += compose_label(name, options)

				# Field options
				field_options = {}
				klass = []
				klass << options[:class] if !options[:class].nil?
				if options[:tinymce] == false
					klass << "form-control"
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

				# Tab header TODO
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

					# Form group
					result += "<div class=\"form-group #{( object.errors[suffixed_name].size > 0 ? "has-error" : "")}\">"
					
					# Text area
					result += text_area(suffixed_name, field_options)

					# Errors
					if object.errors[suffixed_name].size > 0
						result += @template.content_tag(:span, object.errors[suffixed_name][0], :class => "label-danger label")
					end

					# Form group
					result += "</div>"					
					
					# Tab content
					if is_localized
						result += "</div>"
					end

				end

				if is_localized
					result += "</section>"
				end

				return result.html_safe
			end

		end
#	end
end