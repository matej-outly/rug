# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug tabs builder
# *
# * Author: Matěj Outlý
# * Date  : 20. 6. 2016
# *
# *****************************************************************************

module RugBuilder
#	module Gumby
		class TabsBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
				@tabs = []
			end

			def tab(name, heading, &block)
				@tabs << {
					name: name,
					heading: heading.to_s,
					block: block
				}
			end

			#
			# Main render method
			#
			def render(options = {})

				# Find active tab
				active_tab_index = nil
				@tabs.each_with_index do |tab, index|
					if tab[:active] == true
						active_tab_index = index
					end
				end
				if active_tab_index.nil?
					active_tab_index = 0
				end

				# Wrapper
				result = ""
				result += "<section class=\"tabs pill\">"
				
				# Render header
				result += "<ul class=\"tab-nav\">"
				@tabs.each_with_index do |tab, index|
					result += "<li class=\"#{active_tab_index == index ? "active" : ""}\"><a href=\"#\">#{tab[:heading]}</a></li>"
				end
				result += "</ul>"
				
				@tabs.each_with_index do |tab, index|
					
					# Get block
					block = tab[:block]

					# Render tab
					result += "<div class=\"tab-content #{active_tab_index == index ? "active" : ""}\">"
					result += @template.capture(self, &block).to_s
					result += "</div>"
				end

				# Wrapper
				result += "</section>"

				return result.html_safe
			end

		end
#	end
end