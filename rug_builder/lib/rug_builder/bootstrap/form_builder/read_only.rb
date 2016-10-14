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
				
				# Label
				result += compose_label(name, options)

				# Content
				if content.nil?
					content = object.send(name).to_s
				end

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
				result += "<div class=\"form-group #{(object.errors[name].size > 0 ? "has-error" : "")}\">"
			
				# Field
				if format == :input
					result += "<input class=\"#{klass.join(" ")}\" type=\"text\" disabled=\"disabled\" value=\"#{content}\"/>"
				elsif format == :textarea
					result += "<textarea class=\"#{klass.join(" ")}\" disabled=\"disabled\">" + content + "</textarea>"
				end
				
				# Errors
				if object.errors[name].size > 0
					result += @template.content_tag(:span, object.errors[name][0], :class => "label-danger label")
				end

				# Form group
				result += "</div>"

				return result.html_safe
			end

		end
#	end
end