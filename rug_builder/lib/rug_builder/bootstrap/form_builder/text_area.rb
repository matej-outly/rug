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

				result = %{
					<div class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						#{text_area(name, field_options)}
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

		end
#	end
end