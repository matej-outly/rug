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

			# Field
			result += "<div class=\"field\">"
			if format == :input
				result += "<input class=\"text input\" type=\"text\" disabled=\"disabled\" value=\"#{content}\"/>"
			elsif format == :textarea
				result += "<textarea class=\"input textarea\" disabled=\"disabled\">" + content + "</textarea>"
			end
			result += "</div>"
			
			result += "</div>"
			return result.html_safe
		end

	end
end