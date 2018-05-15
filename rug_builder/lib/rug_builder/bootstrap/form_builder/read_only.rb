# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - read only
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def read_only_row(name, content = nil, options = {})
				result = ""
				
				# Content
				content = object.send(name).to_s if content.nil?
				
				# Format
				if options[:format]
					format = options[:format]
				else
					format = :textarea
				end

				# Class
				klass = []
				klass << options[:class] if !options[:class].nil?
				klass << "form-control"
				
				# ID
				id = options[:id] ? options[:id] : "#{object_name}_#{name.to_s}"

				# Form group
				result += "<div class=\"#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}\">"
				result += label_for(name, label: options[:label])
				if format == :input
					options[:suffix] = options[:unit] if options[:unit]
					result += "<div class=\"input-group\">" if options[:prefix] || options[:suffix]
					result += "<span class=\"input-group-addon\">#{options[:prefix]}</span>" if options[:prefix]
					result += "<input id=\"#{id}\" class=\"#{klass.join(" ")}\" type=\"text\" disabled=\"disabled\" value=\"#{content}\"/>"
					result += "<span class=\"input-group-addon\">#{options[:suffix]}</span>" if options[:suffix]
					result += "</div>" if options[:prefix] || options[:suffix]
				elsif format == :textarea
					result += "<textarea id=\"#{id}\" class=\"#{klass.join(" ")}\" disabled=\"disabled\">" + content + "</textarea>"
				end
				result += help_for(name, help: options[:help])
				result += errors(name, errors: options[:errors])
				result += "</div>"

				return result.html_safe
			end

		end
#	end
end