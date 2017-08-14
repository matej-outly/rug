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
#module Bootstrap
	class TabsBuilder

		def initialize(template)
			@template = template	
		end

		def tab(name, heading, options = {}, &block)
			@tabs << {
				name: name.to_sym,
				heading: heading.to_s,
				active: options[:active],
				block: block,
				index: @tabs.length
			}
			return ""
		end

		def self.render_header(tabs = [], options = {})
			
			# Preset
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
					path = "#" + name.to_s.to_id
					data_toggle = "data-toggle=\"tab\""
				end

				result += %{
					<li role="presentation" class="#{active_tab_index == index ? "active" : ""}">
						<a href="#{path}" aria-controls="#{name.to_s.to_id}" role="tab" #{data_toggle}>#{heading}</a>
					</li>
				}
			end
			result += "</ul>"
			result += "</div>" if container

			return result.html_safe
		end

		def render_tab(tab)

			# Block
			block = tab[:block]

			# Render
			result = %{
				<div role="tabpanel" class="tab-pane #{@active_tab_index == tab[:index] ? "active" : ""}" id="#{tab[:name].to_s.to_id}">"
					#{@template.capture(self, &block).to_s}
				</div>
			}

			return result.html_safe
		end

		def render(options = {}, &block)
			
			# Preset
			result = ""
			@tabs = []
			
			# Options
			@options = options

			# Call nested block to capture tabs and its options
			unused = @template.capture(self, &block).to_s

			# Hash
			@hash = Digest::SHA1.hexdigest(@tabs.map{ |tab| tab[:name] }.join("_"))

			# Find active tab
			@active_tab_index = self.class.active_tab_index(@tabs)

			# Header options
			header_options = {}
			@options.each do |key, value|
				if key.to_s.starts_with?("header_")
					header_options[key.to_s[7..-1].to_sym] = value
				end
			end

			# Render header
			header_html = self.class.render_header(@tabs, header_options)
			
			# Render tabs
			tabs_html = ""
			@tabs.each do |tab|
				tabs_html += self.render_tab(tab)
			end

			# Render HTML
			result += %{
				<div id="tabs-#{@hash}">
					#{header_html}
					<div class="tab-content">
						#{tabs_html}
					</div>
				</div>
			}

			# Render JavaScript
			result += @template.javascript_tag(%{
				function tabs_#{@hash}_ready()
				{
					$('#tabs-#{@hash} a[data-toggle="tab"]').on('shown.bs.tab', function() {
						localStorage.setItem('tabs_#{@hash}_active', $(this).attr('href'));
					});
					var activeTab = localStorage.getItem('tabs_#{@hash}_active');
					if (activeTab) {
						$('#tabs-#{@hash} a[href="' + activeTab + '"]').tab('show');
					}
				}
				$(document).ready(tabs_#{@hash}_ready);
			})

			return result.html_safe
		end

	protected

		def self.active_tab_index(tabs = [])
			result = nil
			tabs.each_with_index do |tab, index|
				result = index if tab[:active] == true
			end
			result = 0 if result.nil?
			return result
		end

	end
#end
end