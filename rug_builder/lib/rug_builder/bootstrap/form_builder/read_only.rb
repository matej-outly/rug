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
				
				# Form group
				result += "<div class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"
				result += label_for(name, options)
				if format == :input
					result += "<input class=\"#{klass.join(" ")}\" type=\"text\" disabled=\"disabled\" value=\"#{content}\"/>"
				elsif format == :textarea
					result += "<textarea class=\"#{klass.join(" ")}\" disabled=\"disabled\">" + content + "</textarea>"
				end
				result += errors(name)
				result += "</div>"

				return result.html_safe
			end

		end
#	end
end