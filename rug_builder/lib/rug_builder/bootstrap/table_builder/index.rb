# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - index
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class TableBuilder

			#
			# Render index table
			#
			# Options:
			# - paths (hash) - Define paths to actions:
			#    - show - make column (first column or defined by show_link_column) clickable to display detail
			#    - new - display new button on top
			#    - edit - display edit button with each item
			#    - create - TODO display create form on top
			#    - update - TODO display inline editation form with each item
			#    - destroy - display destroy button with each item
			#    - move - display moving handle with each item
			# - actions (hash) - Define custom actions as combination of path, method, icon, label and show_if condition
			# - global_actions (hash) - Define custom global actions as combination of path, method, icon, label and show_if condition
			# - pagination (boolean) - Turn on pagination
			# - sorting (boolean or hash) - Turn on sorting, can be specified which columns are suitable for sorting
			# - summary (boolean) - Turn on summary
			# - moving (boolean) - Turn on moving
			# - inline_edit (array) - Array of columns suitable for inline edit
			# - inline_destroy (boolean) - Turn on destroy by ajax request
			# - show_link_column (integer) - Column index used for show link
			# - header (string | [string,:h1|:h2|:h3|:h4|:h5|:h6] - optional header displayed in table heading
			#
			def index(objects, columns, options = {})
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

				# Wrapper
				result += %{<div class="index-table">}
				
				# Table heading
				result += index_layout_3(
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
					result += index_layout_6(@options[:class]) do
						I18n.t("views.index_table.empty")
					end
				else
					columns_count = 0	
					result += index_layout_1(@options[:class]) do
						result_1 = ""

						# Table head
						result_1 += "<thead>"
						result_1 += "<tr>"
						if check_moving(@options)
							result_1 += "<th></th>" 
							columns_count += 1
						end
						@columns.headers.each do |column|
							result_1 += "<th>"
							result_1 += @columns.label(column, @model_class)
							result_1 += resolve_sorting(column, @options)
							result_1 += "</th>"
							columns_count += 1
						end
						if @actions
							result_1 += "<th></th>"
							columns_count += 1
						end
						result_1 += "</tr>"
						result_1 += "</thead>"

						# Table body
						result_1 += "<tbody>"
						objects.each do |object|
							
							result_1 += "<tr data-id=\"#{object.id}\" #{check_inline_destroy(@options) ? get_inline_destroy_data(object, @options[:paths][:destroy]) : ""} class=\"#{check_inline_destroy(@options) ? "destroyable" : ""}\">"
							result_1 += "<td class=\"actions\">#{get_moving_link}</td>" if check_moving(@options)
							@columns.headers.each_with_index do |column, idx|
								result_1 += "<td>"
								
								# Standard read only value
								value = @columns.render(column, object).to_s
								if idx == @show_link_column && check_show(@options)
									result_1 += get_show_link(object, value, @options[:paths][:show])
								else
									result_1 += value
								end
								
								result_1 += "</td>"
							end
							if @actions
								result_1 += "<td class=\"actions\">"
								@actions.each do |action, action_spec|
									result_1 += action_spec[:block].call(object)
								end
								result_1 += "</td>"
							end
							result_1 += "</tr>"

						end
						result_1 += "</tbody>"

						result_1
					end

					# Table footer
					result += index_layout_4(
						@options[:class], 
						lambda { resolve_pagination(objects, @options) }, 
						lambda { resolve_summary(objects, @model_class, @options) }
					)

					# Table JS application
					result += @template.javascript_tag(render_js({
						container_selector: "table",
						item_selector_path: "> tbody",
						item_selector: "tr",
						moving_placeholder: index_layout_5(columns_count),
					}))

				end

				# Wrapper
				result += %{</div>}

				return result.html_safe
			end

		protected
			
			# *********************************************************************
			# Index layouts
			# *********************************************************************

			def index_layout_1(klass, &block)
				result = %{
					<table id="index-table-#{@hash}" class="table index-table-body #{(check_moving(@options) ? "moving" : "")} #{klass.to_s}">
						#{block.call}
					</table>
				}
				result
			end

			def index_layout_2(object_id, columns_blocks, actions_block, moving_handle_block)
				# ...
			end

			#
			# Table heading
			#
			def index_layout_3(klass, header_block, actions_block, header_tag = "h2")
				header = header_block.call.trim
				actions = actions_block.call.trim
				result = %{
					<div class="index-table-heading #{klass.to_s} #{actions.blank? && header.blank? ? "empty" : ""}">
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
			def index_layout_4(klass, pagination_block, summary_block)
				pagination = pagination_block.call.trim
				summary = summary_block.call.trim
				result = %{
					<div class="index-table-footer #{klass.to_s} #{pagination.blank? && summary.blank? ? "empty" : ""}">
						#{pagination}
						#{summary}
					</div>
				}
				result
			end

			#
			# Placeholder
			#
			def index_layout_5(columns_count)
				return "<tr class=\"placeholder\">#{"<td></td>" * columns_count}</tr>"
			end

			#
			# Empty table
			#
			def index_layout_6(klass, &block)
				result = %{
					<div class="empty-message index-table-body empty #{klass.to_s}">
						#{block.call}
					</div>
				}
				result
			end
			
		end
#	end
end