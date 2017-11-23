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
			class Body

				def render_as_list(objects)
					
					# Actions will be rendered in its actual place
					@render_action_in_place = true

					# Render
					empty_message = %{<div class="empty-message">#{I18n.t("views.index.empty")}</div>}
					result = %{
						<div 
							id="#{self.id}" 
							class="list #{self.css_class}-body #{@options[:list_class].to_s}"
						>
							#{@options[:empty_message] != false && objects.empty? ? empty_message : ""}
							#{render_items(objects)}
						</div>
					}

					# Render JS
					result += @template.javascript_tag(render_js(
						container_selector: ".list",
						item_selector: ".item",
					))

					return result.html_safe
				end

				def render_items(objects)
					result = ""
					objects.each do |object| 
						result += self.capture_partial(render_item(object)) + "\n"
					end
					return result.html_safe
				end

				def render_item(object)
					
					# Must be captured ahead in order to resolve @destroyable
					item_html = @template.capture(self, object, &@block).to_s

					# Render
					result = %{
						<div 
							class="item #{@destroyable ? "destroyable" : ""} #{@options[:item_class].to_s}"
							data-id=\"#{object.id}\" 
							#{@destroyable ? self.destroyable_data(object) : ""}
						>
							#{item_html}
						</div>
					}
					return result.html_safe
				end

			end
		end
	end
end