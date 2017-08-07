# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug show builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	class ShowBuilder
		module Builders
			class Body
				include RugBuilder::ShowBuilder::Concerns::Utils
				include RugBuilder::Concerns::Columns

				def initialize(template)
					@template = template
					#@path_resolver = RugSupport::PathResolver.new(@template)
					#@icon_builder = RugBuilder::IconBuilder
				end

				# *************************************************************
				# Render
				# *************************************************************

				def render(object, options = {}, &block)
					
					# Save
					@object = object
					@options = options

					# Empty
					@empty = true

					# Capture all columns
					unused = @template.capture(self, &block)

					# Render
					result = render_table
					if @empty
						result = %{
							<div class="#{self.css_class}-body empty #{@options[:class].to_s}">
								#{I18n.t("views.show_table.empty")}
							</div>
						}
					end

					return result.html_safe
				end

				def render_table
					%{
						<table class="table #{self.css_class}-body #{@options[:class].to_s}">
							<tbody>
								#{render_rows}
							</tbody>
						</table>
					}
				end

				def render_rows
					result = ""
					self.columns.keys.each do |column|
						value = self.render_column_value(column, @object)
						if value.is_a?(Array)
							value.each do |item|
								@empty = false
								result += render_row(item[:label], item[:value], :store)
							end
						else
							if @options[:blank_rows] == true || !value.blank?
								@empty = false
								result += render_row(render_column_label(column, self.model_class), value, self.columns[column][:type])
							end
						end
					end
					result
				end

				def render_row(label, value, type)
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
#end
end