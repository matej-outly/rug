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
			# - header (string | [string,:h1|:h2|:h3|:h4|:h5|:h6] - optional header displayed in table heading
			#
			def show(object, columns, options = {})
				result = ""

				# Check
				if object.nil?
					raise "Given object is nil."
				end

				# Options
				@options = options

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
						if options[:header].is_a?(Array)
							options[:header].first.to_s
						else
							options[:header].to_s
						end
					},
					lambda {
						result_3 = ""
						if actions
							actions.each do |action, action_spec|
								result_3 += action_spec[:block].call(object)
							end
						end
						result_3
					},
					(options[:header].is_a?(Array) && options[:header].length >= 2 ? options[:header][1].to_s : "h2")
				)

				# Table
				empty = true
				table_result = show_layout_1(options[:class]) do
					result_1 = ""
					columns.headers.each do |column|
						if columns.is_store?(column)
							columns.render_store(column, object).each do |store_item|
								empty = false
								result_1 += show_layout_2(lambda { store_item[:label] }, lambda { store_item[:value] }, :store)
							end
						else
							value = columns.render(column, object)
							if options[:show_blank_rows] == true || !value.blank?
								empty = false
								result_1 += show_layout_2(lambda { columns.label(column, object.class) }, lambda { value }, columns.type(column))
							end
						end
					end
					result_1
				end

				if empty
					result += show_layout_6(options[:class]) do
						I18n.t("views.index_table.empty")
					end
				else
					result += table_result
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
			def show_layout_2(label_block, value_block, type)
				if type == :text
					result = %{
						<tr>
							<td colspan="2" class="show-table-label">#{label_block.call}</td>
						</tr>
						<tr>
							<td colspan="2" class="show-table-value">#{value_block.call}</td>
						</tr>
					}
				else
					result = %{
						<tr>
							<td class="show-table-label">#{label_block.call}</td>
							<td class="show-table-value">#{value_block.call}</td>
						</tr>
					}
				end
				result
			end

			#
			# Table heading
			#
			def show_layout_3(klass, header_block, actions_block, header_tag = "h2")
				header = header_block.call.trim
				actions = actions_block.call.trim
				result = %{
					<div class="show-table-heading #{klass.to_s} #{actions.blank? && header.blank? ? "empty" : ""}">
						#{ !header.blank? ? "<" + header_tag + ">" + header + "</" + header_tag + ">" : "" }
						<div class="actions">
							#{actions}
						</div>
					</div>
				}
				result
			end

			#
			# Empty table
			#
			def show_layout_6(klass, &block)
				result = %{
					<div class="show-table-empty #{klass.to_s}">
						#{block.call}
					</div>
				}
				result
			end
			
		end
#	end
end