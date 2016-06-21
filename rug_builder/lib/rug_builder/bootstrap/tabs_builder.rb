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
#	module Bootstrap
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
					name: name.to_sym,
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
				result += "<div>"
				
				# Render header
				result += "<ul class=\"nav nav-tabs\" role=\"tablist\">"
				@tabs.each_with_index do |tab, index|
					result += "<li role=\"presentation\" class=\"#{active_tab_index == index ? "active" : ""}\"><a href=\"##{tab[:name]}\" aria-controls=\"#{tab[:name]}\" role=\"tab\" data-toggle=\"tab\">#{tab[:heading]}</a></li>"
				end
				result += "</ul>"
				
				# Content
				result += "<div class=\"tab-content\">"
				@tabs.each_with_index do |tab, index|
					
					# Get block
					block = tab[:block]

					# Render tab
					result += "<div role=\"tabpanel\" class=\"tab-pane #{active_tab_index == index ? "active" : ""}\" id=\"#{tab[:name]}\">"
					result += @template.capture(self, &block).to_s
					result += "</div>"
				end
				result += "</div>"

				# Wrapper
				result += "</div>"

				return result.html_safe
			end

		end
#	end
end