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
			# Render only tabs header
			#
			def self.render_header(tabs = [])
				result = ""
				
				# Find active tab index
				active_tab_index = self.active_tab_index(tabs)

				# Render header
				result += "<ul class=\"tab-nav\">"
				tabs.each_with_index do |tab, index|
					path = tab[:path] ? tab[:path].to_s : "#"
					result += "<li class=\"#{active_tab_index == index ? "active" : ""}\"><a href=\"#{path}\">#{tab[:heading]}</a></li>"
				end
				result += "</ul>"

				return result.html_safe
			end

			#
			# Main render method
			#
			def render(options = {})

				# Wrapper
				result = ""
				result += "<section class=\"tabs pill\">"
				
				# Render header
				result += self.class.render_header(@tabs)

				# Find active tab
				active_tab_index = self.class.active_tab_index(@tabs)

				# Render content
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

		protected

			#
			# Find active tab index
			#
			def self.active_tab_index(tabs = [])
				result = nil
				tabs.each_with_index do |tab, index|
					if tab[:active] == true
						result = index
					end
				end
				if result.nil?
					result = 0
				end
				return result
			end

		end
#	end
end