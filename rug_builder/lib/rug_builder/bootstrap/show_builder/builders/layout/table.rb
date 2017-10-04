# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug show builder
# *
# * Author: Matěj Outlý
# * Date  : 2. 10. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	class ShowBuilder
		module Builders
			class Body

				def render_as_table
					%{
						<table class="table #{self.css_class}-body #{@options[:class].to_s}">
							<tbody>
								#{render_table_rows}
							</tbody>
						</table>
					}
				end

				def render_table_rows
					result = ""
					self.columns.keys.each do |column|
						value = self.render_column_value(column, @object)
						if value.is_a?(Array)
							value.each do |item|
								@empty = false
								if self.columns[column][:action]
									value = self.render_link(self.columns[column][:action].merge(
										label: item[:value],
										fallback: item[:value], 
										default_label: "...",
										object: @object, 
										disable_button: true, 
									))
								else
									value = item[:value]
								end
								result += render_table_row(item[:label], value, :store)
							end
						else
							if @options[:blank_rows] == true || !value.blank?
								@empty = false
								if self.columns[column][:action]
									value = self.render_link(self.columns[column][:action].merge(
										label: value,
										fallback: value, 
										default_label: "...",
										object: @object, 
										disable_button: true, 
									))
								end
								result += render_table_row(render_column_label(column, self.model_class), value, self.columns[column][:type])
							end
						end
					end
					result
				end

				def render_table_row(label, value, type)
					%{
						<tr>
							<td class="#{self.css_class}-label">#{label}</td>
							<td class="#{self.css_class}-value">#{value}</td>
						</tr>
					}
				end

			end
		end
	end
end