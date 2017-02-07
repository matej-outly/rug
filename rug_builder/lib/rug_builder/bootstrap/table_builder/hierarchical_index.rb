# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - hierarchical index
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class TableBuilder

			#
			# Render hierarchical index table
			#
			# Options:
			# - paths (hash) - Define paths to actions:
			#    - show - make column (first column or defined by show_link_column) clickable to display detail
			#    - new - display new button on top
			#    - edit - display edit button with each item
			#    - create - TODO display create form on top
			#    - update - TODO display inline editation form with each item
			#    - destroy - display destroy button with each item
			#    - move_up - display moving handle with each item
			#    - move_down - display moving handle with each item
			# - actions (hash) - Define custom actions as combination of path, method, icon, label and show_if condition
			# - global_actions (hash) - Define custom global actions as combination of path, method, icon, label and show_if condition
			# - summary (boolean) - Turn on summary
			# - moving (boolean) - Turn on moving
			# - inline_edit (array) - array of columns suitable for inline edit
			# - show_link_column (integer) - Column index used for show link
			# - header (string | [string,:h1|:h2|:h3|:h4|:h5|:h6] - optional header displayed in table heading
			#
			def hierarchical_index(objects, columns, options = {})
				result = ""
				
				# Model class
				@model_class = get_model_class(objects, options)

				# Unique hash
				@hash = get_model_class_hash(@model_class)

				# Options
				@options = options

				# Normalize columns
				@columns = normalize_columns(columns)
				
				# Show link column
				if @options[:show_link_column]
					@show_link_column = @options[:show_link_column]
				else
					@show_link_column = 0
				end

				# Prepare global actions
				@global_actions = prepare_actions(@options, :global_actions, [:new], size: "sm", label: false)

				# Prepare actions
				@actions = prepare_actions(@options, :actions, [:edit, :destroy], label: false)

				# Hierarchical
				maximal_level = @model_class.maximal_level 
				open_siblings = {}
				open_levels = {}

				# Table heading
				result += hierarchical_index_layout_3(
					@options[:class], 
					lambda {
						if @options[:header].is_a?(Array)
							@options[:header].first.to_s
						else
							@options[:header].to_s
						end
					},
					lambda {
						result_3 = ""
						if @global_actions
							@global_actions.each do |action, action_spec|
								result_3 += action_spec[:block].call(nil)
							end
						end
						result_3
					},
					(@options[:header].is_a?(Array) && @options[:header].length >= 2 ? @options[:header][1].to_s : "h2")
				)

				if objects.empty?
					result += hierarchical_index_layout_6(@options[:class]) do
						I18n.t("views.index_table.empty")
					end
				else
					result += hierarchical_index_layout_1(@options[:class]) do
						result_1 = ""

						# Table head
						result_1 += "<thead>"
						result_1 += "<tr>"
						result_1 += "<th></th><th></th>" if check_moving(@options, hierarchical: true)
						result_1 += "<th colspan=\"2\">#{ I18n.t("general.nesting").upcase_first }</th>"
						@columns.headers.each_with_index do |column, idx|
							if idx == 0
								result_1 += "<th colspan=\"#{ maximal_level + 1 }\">#{ @columns.label(column, @model_class) }</th>"
							else
								result_1 += "<th>#{ @columns.label(column, @model_class) }</th>"
							end
						end
						if @actions
							result_1 += "<th></th>"
						end
						result_1 += "</tr>"
						result_1 += "</thead>"

						# Table body
						result_1 += "<tbody>"
						idx = 0
						@model_class.each_plus_dummy_with_level(objects) do |object, level|
							
							if !object.nil?
								
								# Node
								result_1 += "<tr data-id=\"#{object.id}\">"
								
								# Moving
								if check_moving(@options, hierarchical: true)
									result_1 += "<td class=\"standard action\">" 
									result_1 += get_moving_up_link(object, @options[:paths][:move_up])
									result_1 += "</td><td class=\"standard action\">" 
									result_1 += get_moving_down_link(object, @options[:paths][:move_down])
									result_1 += "</td>" 
								end

								# Nesting 
								open_siblings[level] = false 
								open_levels[level] = object.id
								(0..level-1).each do |zero_level|
									if open_siblings[zero_level] == true
										result_1 += "<td class=\"nesting nesting-0-inner\"></td>"
									else
										result_1 += "<td class=\"nesting nesting-0-none\"></td>"
									end
								end
								if object.right_sibling == nil
									result_1 += "<td class=\"nesting nesting-1-nosibling\"></td>"
								else
									open_siblings[level] = true
									result_1 += "<td class=\"nesting nesting-1-sibling\"></td>"
								end
								if object.leaf?
									result_1 += "<td class=\"nesting nesting-2-nochild\"></td>"
								else
									result_1 += "<td class=\"nesting nesting-2-child\"></td>"
								end

								# Columns
								@columns.headers.each_with_index do |column, column_idx|
									value = @columns.render(column, object)
									if column_idx == 0
										result_1 += "<td class=\"leaf\" colspan=\"#{ (maximal_level + 1 - level) }\">"
									else
										result_1 += "<td>"
									end
									if column_idx == @show_link_column && check_show(@options)
										result_1 += get_show_link(object, value, @options[:paths][:show])
									else
										result_1 += value
									end
									result_1 += "</td>"
								end

								# Actions
								if @actions
									result_1 += "<td class=\"custom action\">"
									@actions.each do |action, action_spec|
										result_1 += action_spec[:block].call(object)
									end
									result_1 += "</td>"
								end
								result_1 += "</tr>"

							end
							idx += 1
						end
						result_1 += "</tbody>"

						result_1
					end

					# Table footer
					result += hierarchical_index_layout_4(
						@options[:class], 
						lambda { resolve_summary(objects, @model_class, @options) }
					)
					
					# Inline edit JS
					#result += resolve_inline_edit_js(hash, @options)

				end

				return result.html_safe
			end

		protected

			# *********************************************************************
			# Hierarchical index layouts
			# *********************************************************************

			def hierarchical_index_layout_1(klass, &block)
				result = %{
					<table id="index-table-#{@hash}" class="table hierarchical-index-table #{klass.to_s}">
						#{block.call}
					</table>
				}
				result
			end

			def hierarchical_index_layout_2(object_id, columns_blocks, actions_block)
				# ...
			end

			#
			# Table heading
			#
			def hierarchical_index_layout_3(klass, header_block, actions_block, header_tag = "h2")
				header = header_block.call.trim
				actions = actions_block.call.trim
				result = %{
					<div class="hierarchical-index-table-heading #{klass.to_s} #{actions.blank? && header.blank? ? "empty" : ""}">
						#{ !header.blank? ? "<" + header_tag + ">" + header + "</" + header_tag + ">" : "" }
						<div class="actions">
							#{actions}
						</div>
					</div>
				}
				result
			end

			#
			# Table footer
			#
			def hierarchical_index_layout_4(klass, summary_block)
				summary = summary_block.call.trim
				result = %{
					<div class="hierarchical-index-table-footer #{klass.to_s} #{summary.blank? ? "empty" : ""}">
						#{summary}
					</div>
				}
				result
			end

			#
			# Placeholder
			#
			def hierarchical_index_layout_5(columns_count)
				return "<tr class=\"placeholder\">#{"<td></td>" * columns_count}</tr>"
			end

			#
			# Empty table
			#
			def hierarchical_index_layout_6(klass, &block)
				result = %{
					<div class="empty-message hierarchical-index-table-empty #{klass.to_s}">
						#{block.call}
					</div>
				}
				result
			end
			
		end
#	end
end