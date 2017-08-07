# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug index builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	class IndexBuilder
		module Builders
			class Footer
				include RugBuilder::IndexBuilder::Concerns::Utils
				include RugBuilder::IndexBuilder::Concerns::Additionals
				include RugBuilder::Concerns::Actions
				
				def initialize(template)
					@template = template
					@path_resolver = RugSupport::PathResolver.new(@template)
					@icon_builder = RugBuilder::IconBuilder
				end

				def render(objects, options = {}, &block)

					# Save
					@objects = objects
					@options = options

					# Render
					html = ""
					html += @template.capture(self, &block).to_s
					html += render_actions
					result = %{
						<div class="#{self.css_class}-footer #{html.trim.blank? ? "empty" : ""} #{options[:class].to_s}">
							#{html}
						</div>
					}
					return result.html_safe
				end

				def render_actions
					result = ""
					result += %{<div class="actions">}
					self.actions.keys.each do |action|
						result += self.render_action_link(action, size: "sm") + " "
					end
					result += %{</div>}
					return result.html_safe
				end

			end
		end
	end
#end
end