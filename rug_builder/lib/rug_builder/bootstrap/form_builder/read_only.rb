# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - read only TODO
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def read_only_row(name, content = nil, options = {})
				result = "<div class=\"element\">"
				
				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label])
					end
				else
					result += label(name)
				end

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
				if format == :input
					klass << "text input"
				elsif format == :textarea
					klass << "input textarea"
				end

				# Field
				result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
				if format == :input
					result += "<input class=\"#{klass.join(" ")}\" type=\"text\" disabled=\"disabled\" value=\"#{content}\"/>"
				elsif format == :textarea
					result += "<textarea class=\"#{klass.join(" ")}\" disabled=\"disabled\">" + content + "</textarea>"
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
#	end
end