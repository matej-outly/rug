# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - picture index
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class TableBuilder

			#
			# Render picture index table
			#
			# Options:
			# - paths (hash) - Define paths to actions:
			#    - show - make picture clickable to show detail
			#    - new - display new button on top
			#    - edit - display edit button with each item
			#    - create - TODO display create form on top
			#    - update - TODO display inline edit form with each item
			#    - destroy - display destroy button with each item
			#    - move - display moving handle with each item
			# - actions (hash) - Define custom actions as combination of path, method, icon, label and show_if condition
			# - global_actions (hash) - Define custom global actions as combination of path, method, icon, label and show_if condition
			# - pagination (boolean) - Turn on pagination
			# - summary (boolean) - Turn on summary
			# - moving (boolean) - Turn on moving
			# - show_link_column (integer) - Column index used for show link
			# - header (string | [string,:h1|:h2|:h3|:h4|:h5|:h6] - optional header displayed in table header
			# - grid_columns (integer) - Number of columns in the grid (default 3)
			# - thumbanail_crop (indeger) - Height of thumbnail in px if it should be cropped (default no crop)
			#
			def picture_index(objects, columns, options = {})
				result = ""

				# Model class
				@model_class = get_model_class(objects, options)

				# Unique hash
				@hash = get_model_class_hash(@model_class)

				# Options
				@options = options

				# Normalize columns
				@columns = normalize_columns(columns)

				# Prepare global actions
				@global_actions = prepare_actions(@options, :global_actions, [:new], size: "sm")

				# Prepare actions
				@actions = prepare_actions(@options, :actions, [:edit, :destroy], size: "sm")

				# Show link column
				if @options[:show_link_column]
					@show_link_column = @options[:show_link_column]
				else
					@show_link_column = 0
				end

				# Grid columns
				@grid_columns = 3
				@grid_columns = @options[:grid_columns] if @options[:grid_columns]

				# Thumbnail crop
				@thumbnail_crop = nil
				@thumbnail_crop = @options[:thumbnail_crop] if @options[:thumbnail_crop]

				# Table heading
				result += picture_index_layout_3(
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

				# Table
				result += picture_index_layout_1("#{(check_moving(@options) ? "moving" : "")} #{@options[:class].to_s}") do
					if objects.empty?
						result_1 = picture_index_layout_6(@options[:class]) do
							I18n.t("views.index_table.empty")
						end
						result_1
					else
						result_1 = ""
						objects.each do |object|
							result_1 += picture_index_object(object)
						end
						result_1
					end
				end

				# Table footer
				result += picture_index_layout_4(
					@options[:class], 
					lambda { resolve_pagination(objects, @options) }, 
					lambda { resolve_summary(objects, @model_class, @options) }
				)

				# Table JS library
				result += @template.javascript_tag(js_library)

				# Table JS application
				result += @template.javascript_tag(js_application({
					container_selector: ".list",
					item_selector: ".item",
					item_template: picture_index_object(@columns.template_object),
					moving_placeholder: picture_index_layout_5,
				}))
				
				return result.html_safe
			end

		protected

			def picture_index_object(object)

				# Define render block for each column
				columns_blocks = []
				@columns.headers.each_with_index do |column, idx|
					columns_blocks << lambda {
						value = @columns.render(column, object)
						if idx == @show_link_column && check_show_link(@options)
							get_show_link(object, value, @options[:paths][:show])
						else
							value
						end
					}
				end

				# Define render block actions for actions
				actions_block = lambda {
					result = ""
					if @actions
						@actions.each do |action, action_spec|
							result += action_spec[:block].call(object)
						end
					end
					result
				}

				# Define render block actions for moving handle
				moving_handle_block = lambda {
					result = ""
					result += get_moving_link(size: "sm") if check_moving(@options)
					result
				}

				# Use layout to render single item
				return picture_index_layout_2(object.id, columns_blocks, actions_block, moving_handle_block)
			end

			#
			# Main table
			#
			def picture_index_layout_1(klass, &block)
				result = %{
					<div id="index-table-#{@hash}" class="list picture-index-table row #{klass.to_s}">
						#{block.call}
					</div>
				}
				result
			end

			#
			# Single object
			#
			def picture_index_layout_2(object_id, columns_blocks, actions_block, moving_handle_block)
				actions = actions_block.call.trim
				first_column_block = columns_blocks.shift
				col_sm = 6
				col_md = 12 / @grid_columns
				result = ""
				result += %{
					<div class="item col-sm-#{col_sm} col-md-#{col_md}" data-id=\"#{object_id}\">
						#{moving_handle_block.call}
						<div class="thumbnail">
				}
				if !@thumbnail_crop.nil?
					result += %{
							<span class="thumbnail-crop thumbnail-crop-horizontal" style="height: #{@thumbnail_crop}px; width: 100%;">
					}
				end
				
				# Picture
				result += first_column_block.call if first_column_block
				
				if !@thumbnail_crop.nil?	
					result += %{		
							</span>
					}
				end
				result += %{
							<div class="caption">
				}
				columns_blocks.each_with_index do |column_block, index|
					if index == 0 
						result += "<h5>" + column_block.call + "</h5>"
					else
						result += column_block.call
					end
				end
				result += %{
								#{!actions.blank? ? "<hr/>" + actions : ""}
							</div>
						</div>	
					</div>
				}
				result
			end

			#
			# Table heading
			#
			def picture_index_layout_3(klass, header_block, actions_block, header_tag = "h2")
				header = header_block.call.trim
				actions = actions_block.call.trim
				result = %{
					<div class="picture-index-table-heading #{klass.to_s} #{actions.blank? && header.blank? ? "empty" : ""}">
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
			def picture_index_layout_4(klass, pagination_block, summary_block)
				pagination = pagination_block.call.trim
				summary = summary_block.call.trim
				result = %{
					<div class="picture-index-table-footer #{klass.to_s} #{pagination.blank? && summary.blank? ? "empty" : ""}">
						#{pagination}
						#{summary}
					</div>
				}
				result
			end

			#
			# Moving placeholder
			#
			def picture_index_layout_5
				return "<div class=\"placeholder col-sm-6 col-md-4\"></div>"
			end

			#
			# Empty table
			#
			def picture_index_layout_6(klass, &block)
				result = %{
					<div class="empty-message picture-index-table-empty #{klass.to_s}">
						#{block.call}
					</div>
				}
				result
			end
			
		end
#	end
end