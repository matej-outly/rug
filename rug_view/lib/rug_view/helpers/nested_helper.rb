# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 1. 7. 2015
# *
# *****************************************************************************

module RugView
	module Helpers
		module NestedHelper

			def nested_ul(objects, &block)
				return "" if objects.size == 0

				output = ""
				path = [objects.first.parent_id]

				objects.each_with_index do |object, idx|
					
					# get li content and parse css class
					content = capture(object, &block)
					matches = content.match(/class="([^"]*)"/)
					if matches
						css_class = matches[1]
					else
						css_class = ""
					end

					# Draw ul/li tags
					if idx == 0
						output << "<ul><li class=\"#{css_class}\">"
					end
					if object.parent_id != path.last
						# We are on a new level, did we descend or ascend?
						if path.include?(object.parent_id)
							# Remove the wrong trailing path elements
							while path.last != object.parent_id
								path.pop
								output << "</li></ul>"
							end
							output << "</li><li class=\"#{css_class}\">"
						else
							path << object.parent_id
							output << "<ul><li class=\"#{css_class}\">"
						end
					elsif idx != 0
						output << "</li><li class=\"#{css_class}\">"
					end

					# Draw content
					output << content

				end

				# Draw ul/li tags
				output << "</li></ul>" * path.length
				
				# Result
				return output.html_safe
			end

		end
	end
end
