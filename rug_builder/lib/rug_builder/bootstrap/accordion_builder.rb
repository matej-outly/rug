# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug accordion builder
# *
# * Author: Matěj Outlý
# * Date  : 9. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	class AccordionBuilder

		def initialize(template)
			@template = template
		end

		def header(label, options = {}, &block)
			result = ""
			if @current_tab
				result += %{
					<div class="panel-heading" role="tab" id="accordion-#{@hash}-#{@current_tab[:name].to_s.to_id}-heading" class=" #{options[:class]}">
						<h4 class="panel-title #{options[:title_class]}">
							<a role="button" data-toggle="collapse" data-parent="#accordion-#{@hash}" href="#accordion-#{@hash}-#{@current_tab[:name].to_s.to_id}" aria-expanded="true" aria-controls="accordion-#{@hash}-#{@current_tab[:name].to_s.to_id}">
								#{label}
							</a>
						</h4>
						#{block ? @template.capture(&block).to_s : ""}
					</div>
				}
			end
			return result.html_safe
		end

		def body(options = {}, &block)
			result = ""
			if @current_tab
				result += %{
					<div id="accordion-#{@hash}-#{@current_tab[:name].to_s.to_id}" class="panel-collapse collapse #{@current_tab[:index] == self.active_tab_index ? "in" : ""}" role="tabpanel" aria-labelledby="accordion-#{@hash}-#{@current_tab[:name].to_s.to_id}-heading">
						#{options[:wrap] != false ? "<div class=\"panel-body\">" : ""}
							#{@template.capture(&block).to_s}
						#{options[:wrap] != false ? "</div>" : ""}
					</div>
				}
			end
			return result.html_safe
		end

		def tab(name, options = {}, &block)
			@tabs << {
				name: name.to_sym,
				options: options,
				block: block,
				index: @tabs.length
			}
			return ""
		end

		def render_tab(tab, index)

			# Block
			block = tab[:block]

			# Render
			@current_tab = tab
			result = %{
				<div class="panel panel-default">
					#{@template.capture(self, &block).to_s}
				</div>
			}
			@current_tab = nil

			return result.html_safe
		end

		def render(options = {}, &block)

			# Preset
			result = ""
			@tabs = []
			
			# Options
			@options = options

			# Capture must be called in advance because we need all tabs for hash
			unused = @template.capture(self, &block).to_s

			# Hash
			@hash = Digest::SHA1.hexdigest(@tabs.map{ |tab| tab[:name] }.join("_"))

			# Render tabs
			tabs_html = ""
			@tabs.each_with_index do |tab, index|
				tabs_html += self.render_tab(tab, index)
			end

			# Render HTML
			result += %{
				<div class="accordion panel-group" id="accordion-#{@hash}" role="tablist" aria-multiselectable="true">
					#{tabs_html}
				</div>
			}

			# Render JavaScript
			result += @template.javascript_tag(%{
				function accordion_#{@hash}_store()
				{
					if ($('#accordion-#{@hash} .collapse.in').length > 0) {
						localStorage.setItem('accordion_#{@hash}_active', $('#accordion-#{@hash} .collapse.in').attr('id'));
					} else {
						localStorage.setItem('accordion_#{@hash}_active', 'none');
					}
				}
				function accordion_#{@hash}_ready()
				{
					$('#accordion-#{@hash} .collapse').on('shown.bs.collapse', function() {
						accordion_#{@hash}_store();
					});
					$('#accordion-#{@hash} .collapse').on('hidden.bs.collapse', function() {
						accordion_#{@hash}_store();
					});
					var activeTab = localStorage.getItem('accordion_#{@hash}_active');
					if (activeTab) {
						$('#accordion-#{@hash} .collapse').removeClass('in');
						if (activeTab != 'none') {
							$('#' + activeTab).addClass('in');
						}
					}
				}
				$(document).ready(accordion_#{@hash}_ready);
			})

			return result.html_safe
		end

	protected

		def active_tab_index
			if @active_tab_index.nil? && @options[:active] != false
				@tabs.each_with_index do |tab, index|
					@active_tab_index = index if tab[:options] && tab[:options][:active] == true
				end
				@active_tab_index = 0 if @active_tab_index.nil?
			end
			return @active_tab_index
		end

	end
#end
end