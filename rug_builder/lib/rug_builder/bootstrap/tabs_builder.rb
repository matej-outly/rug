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
			# Render only tabs header
			#
			def self.render_header(tabs = [], options = {})
				result = ""
				
				# Class and container class
				klass = options[:class] ? options[:class] : ""
				container_klass = options[:container_class] ? options[:container_class] : ""
				container = !container_klass.blank?

				# Style
				style = options[:style] ? options[:style] : "tabs"

				# Find active tab index
				active_tab_index = self.active_tab_index(tabs)

				# Render header
				result += "<div class=\"#{container_klass}\">" if container
				result += "<ul class=\"nav nav-#{style} #{klass}\" role=\"tablist\">"
				tabs.each_with_index do |tab, index|

					# Attributes
					name = tab[:name] ? tab[:name].to_s : ""
					heading = tab[:heading] ? tab[:heading].to_s : ""
					if tab[:path]
						path = tab[:path].to_s
						data_toggle = ""
					else
						path = "#" + name
						data_toggle = "data-toggle=\"tab\""
					end

					result += "<li role=\"presentation\" class=\"#{active_tab_index == index ? "active" : ""}\"><a href=\"#{path}\" aria-controls=\"#{name}\" role=\"tab\" #{data_toggle}>#{heading}</a></li>"
				end
				result += "</ul>"
				result += "</div>" if container

				return result.html_safe
			end

			#
			# Main render method
			#
			def render(options = {})

				# Hash
				hash = Digest::SHA1.hexdigest(@tabs.map{ |tab| tab[:name] }.join("_"))

				# Wrapper
				result = ""
				result += "<div id=\"tabs_#{hash}\">"
				
				# Header options
				header_options = {}
				options.each do |key, value|
					if key.to_s.starts_with?("header_")
						header_options[key.to_s[7..-1].to_sym] = value
					end
				end

				# Render header
				result += self.class.render_header(@tabs, header_options)
				
				# Find active tab
				active_tab_index = self.class.active_tab_index(@tabs)

				# Render content
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

				# Render JavaScript
				js = ""
				js += "function tabs_#{hash}_ready()\n"
				js += "{\n"
				js += "	$('#tabs_#{hash} a[data-toggle=\"tab\"]').on('shown.bs.tab', function() {\n"
				js += "		localStorage.setItem('tabs_#{hash}_active', $(this).attr('href'));\n"
				js += "	});\n"
				js += "	var tab_to_show = localStorage.getItem('tabs_#{hash}_active');\n"
				js += "	if (tab_to_show) {\n"
				js += "		$('#tabs_#{hash} a[href=\"' + tab_to_show + '\"]').tab('show');\n"
				js += "	}\n"
				js += "}\n"
				js += "$(document).ready(tabs_#{hash}_ready);\n"

				result += @template.javascript_tag(js)

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