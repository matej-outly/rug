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

				def render_as_table(objects)
					%{
						<table 
							id="index-table-#{self.hash}" 
							class="table #{self.css_class}-body #{@moving ? "moving" : ""} #{@options[:class].to_s}"
							#{@moving ? self.moving_data : ""}
						>
							#{render_table_head}
							#{render_table_body}
						</table>
						#{@template.javascript_tag(render_js(
							container_selector: "table",
							item_selector_path: "> tbody",
							item_selector: "tr",
							moving_placeholder: render_table_row_placeholder
						))}
					}
				end

				def render_table_head
					result = ""
					result += %{<thead>}
					result += %{<tr>}
					@verticals_count = 0
					self.verticals.chunk { |vertical| vertical[:type] }.each do |type, chunk|
						if type == :column
							chunk.each do |vertical|
								column = vertical[:column]
								result += %{<th>}
								result += self.render_column_label(column, self.model_class)
								result += %{</th>}
								@verticals_count += 1
							end
						elsif type == :action
							result += %{<th></th>}
							@verticals_count += 1
						end
					end
					result += %{</tr>}
					result += %{</thead>}
					return result
				end

				def render_table_body
					result = ""
					result += %{<tbody>\n}
					@objects.each do |object|
						result += %{<tr 
							data-id="#{object.id}" 
							class="#{@destroyable ? "destroyable" : ""}"
							#{@destroyable ? self.destroyable_data(object) : ""}
						>}
						self.verticals.chunk { |vertical| vertical[:type] }.each do |type, chunk|
							if type == :column
								chunk.each do |vertical|
									column = vertical[:column]
									result += %{<td>}
									value = self.render_column_value(column, object).to_s
									if self.shows[column]
										result += self.render_link(self.shows[column].merge(
											label: value,
											fallback: value, 
											default_label: "...",
											object: object, 
											disable_button: true, 
										))
									else
										result += value
									end
									result += %{</td>}
								end
							elsif type == :action
								result += %{<td class="actions">}
								chunk.each do |vertical|
									action = vertical[:action]
									result += self.render_action_link(action, object: object, size: "xs", label: false) + " "
								end
								result += %{</td>}
							end
						end
						result += %{</tr>\n}
					end
					result += %{</tbody>\n}
					return result
				end

				def render_table_row_placeholder
					%{<tr class="placeholder">#{"<td></td>" * @verticals_count.to_i}</tr>}
				end

			end
		end
	end
end