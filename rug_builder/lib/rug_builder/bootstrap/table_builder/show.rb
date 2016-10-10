# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - show
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class TableBuilder

			#
			# Render show table
			#
			# Options:
			# - show_blank_rows (boolean) - Turn on rows without any content
			# - paths (hash) - Define paths to new, edit and destroy actions
			# - actions (hash) - Define custom global actions as combination of path, method, icon, label and show_if condition
			#
			def show(object, columns, options = {})
				result = ""

				# Check
				if object.nil?
					raise "Given object is nil."
				end

				# Normalize columns to Columns object
				columns = normalize_columns(columns)

				# Prepare global actions
				actions = prepare_actions(options, :actions, [:new, :edit, :destroy], size: "sm")

				# Show panel parts
				#show_panel_heading = !actions.empty?
				
				# Table heading
				result += show_layout_3(
					options[:class],
					lambda {
						result_3 = ""
						if actions
							actions.each do |action, action_spec|
								result_3 += action_spec[:block].call(object)
							end
						end
						result_3
					}
				)

				# Table
				result += show_layout_1(options[:class]) do
					result_1 = ""
					columns.headers.each do |column|
						value = columns.render(column, object)
						if options[:show_blank_rows] == true || !value.blank?
							result_1 += show_layout_2(lambda { columns.label(column, object.class) }, lambda { value })
						end
					end
					result_1
				end

				return result.html_safe
			end

		protected

			#
			# Main table
			#
			def show_layout_1(klass, &block)
				result = %{
					<table class="table table-curved show-table #{klass.to_s}">
						<tbody>
							#{block.call}
						</tbody>
					</table>
				}
				result
			end

			#
			# Single column
			#
			def show_layout_2(label_block, value_block)
				result = %{
					<tr>
						<td>#{label_block.call}</td>
						<td>#{value_block.call}</td>
					</tr>
				}
				result
			end

			#
			# Table heading
			#
			def show_layout_3(klass, actions_block)
				result = %{
					<div class="show-table-heading #{klass.to_s}">
						<div class="actions">
							#{actions_block.call}
						</div>
					</div>
				}
				result
			end
			
		end
#	end
end