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

#			def text_area_row_old_tabs(name, options = {})
#				result = ""
#				
#				# Label
#				result += label_for(name, options)#

#				# Field options
#				field_options = {}
#				klass = []
#				klass << options[:class] if !options[:class].nil?
#				if options[:tinymce] == false
#					klass << "form-control"
#				elsif !options[:tinymce].nil?
#					klass << options[:tinymce]
#				else
#					klass << "tinymce"
#				end
#				field_options[:class] = klass.join(" ")
#				field_options[:id] = options[:id] if !options[:id].nil?
#				field_options[:data] = options[:data] if !options[:data].nil?#

#				# Localization
#				if options[:localization].nil? || options[:localization] == false
#					localization = [nil]
#					is_localized = false
#				else
#					if options[:localization].is_a?(Array)
#						localization = options[:localization]
#					else
#						localization = I18n.available_locales
#					end
#					is_localized = true
#				end#

#				# Tab header TODO do with tab builder
#				if is_localized
#					result += "<section class=\"tabs pill minimal\">"
#					result += "<ul class=\"tab-nav\">"
#					localization.each_with_index do |locale, index|
#						result += "<li class=\"#{(index == 0 ? "active" : "")}\"><a href=\"#\">#{locale.to_s.upcase}</a></li>"
#					end
#					result += "</ul>"
#				end#

#				localization.each_with_index do |locale, index|
#					
#					# Tab content
#					if is_localized
#						result += "<div class=\"tab-content #{(index == 0 ? "active" : "")}\">"
#						suffixed_name = (name.to_s + "_#{locale.to_s}").to_sym
#					else
#						suffixed_name = name
#					end#

#					# Form group
#					result += "<div class=\"form-group #{(has_error?(suffixed_name) ? "has-error" : "")}\">"
#					
#					# Text area
#					result += text_area(suffixed_name, field_options)#

#					# Errors
#					result += errors(suffixed_name)#

#					# Form group
#					result += "</div>"					
#					
#					# Tab content
#					if is_localized
#						result += "</div>"
#					end#

#				end#

#				if is_localized
#					result += "</section>"
#				end#

#				return result.html_safe
#			end

			def text_area_row(name, options = {})
				result = ""
				
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
				field_options[:data] = options[:data] if !options[:data].nil?
				field_options[:placeholder] = options[:placeholder] if !options[:placeholder].nil?

				# Form group
				result += "<div class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"
				result += label_for(name, options)
				result += text_area(name, field_options)
				result += errors(name)
				result += "</div>"

				return result.html_safe
			end

		end
#	end
end