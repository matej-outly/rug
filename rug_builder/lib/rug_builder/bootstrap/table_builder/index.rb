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
			# - inline_edit (array) - array of columns suitable for inline edit
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
					result += index_layout_1("#{(check_moving(@options) ? "moving" : "")} #{@options[:class].to_s}") do
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
							
							result_1 += "<tr data-id=\"#{object.id}\">"
							result_1 += "<td class=\"standard action\">#{get_moving_link}</td>" if check_moving(@options)
							@columns.headers.each_with_index do |column, idx|
								result_1 += "<td>"
								#if check_inline_edit(@options, column)
								#	result_1 += "<div class=\"inline-edit value\">"
								#end

								# Standard read only value
								value = @columns.render(column, object).to_s
								if idx == @show_link_column && check_show_link(@options)
									result_1 += get_show_link(object, value, @options[:paths][:show])
								else
									result_1 += value
								end
								
								#if check_inline_edit(@options, column)
								#	result_1 += "</div>"
								#	result_1 += "<div class=\"inline-edit field\" style=\"display: none;\">#{get_inline_edit_field(object, column, columns.render(column, object), model_class)}</div>"
								#end
								result_1 += "</td>"
							end
							if @actions
								result_1 += "<td class=\"custom action\">"
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

					# Table JS library
					result += @template.javascript_tag(js_library)

					# Table JS application
					result += @template.javascript_tag(js_application({
						container_selector: "table",
						item_selector_path: "> tbody",
						item_selector: "tr",
						moving_placeholder: index_layout_5(columns_count),
					}))

				end

				return result.html_safe
			end

		protected
			
			# *********************************************************************
			# Index layouts
			# *********************************************************************

			def index_layout_1(klass, &block)
				result = %{
					<table id="index-table-#{@hash}" class="table index-table #{klass.to_s}">
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
					<div class="index-table-empty #{klass.to_s}">
						#{block.call}
					</div>
				}
				result
			end

			# *********************************************************************
			# Moving
			# *********************************************************************

			def resolve_moving_js(hash, options, markup = {})
				if check_moving(options)
					js = %{
						function index_table_#{hash}_moving_ready()
						{
							$('#index-table-#{hash}.moving').sortable({
								containerSelector: '#{markup[:container_selector].to_s}',
								itemPath: '#{markup[:item_path].to_s}',
								itemSelector: '#{markup[:item_selector].to_s}',
								placeholder: '#{markup[:placeholder].to_s}',
								handle: '.moving-handle',
								onDrop: function ($item, container, _super, event) {
									$item.removeClass(container.group.options.draggedClass).removeAttr('style');
									$('body').removeClass(container.group.options.bodyClass);
									var id = $item.data('id');
									var prev_id = $item.prev().data('id') ? $item.prev().data('id') : undefined;
									var next_id = $item.next().data('id') ? $item.next().data('id') : undefined;
									if (prev_id || next_id) {
										var destination_id = prev_id;
										var relation = 'right';
										if (!destination_id) {
											destination_id = next_id;
											relation = 'left';
										}
										var move_url = '#{@path_resolver.resolve(options[:paths][:move], ":id", ":relation", ":destination_id")}'.replace(':id', id).replace(':relation', relation).replace(':destination_id', destination_id);
										$.ajax({url: move_url, method: 'PUT', dataType: 'json'});
									}
								}
							});
						}
						$(document).ready(index_table_#{hash}_moving_ready);
					}
					return @template.javascript_tag(js)
				else
					return ""
				end
			end

			# *********************************************************************
			# Inline editation
			# *********************************************************************

#			def resolve_inline_edit_js(hash, options)
#				if check_inline_edit(options)#

#					js = ""
#					js += "function index_table_#{hash}_inline_edit_ready()\n"
#					js += "{\n"
#					js += "	$('#index-table-#{hash} a.inline-edit.edit').on('click', function(e) {\n"
#					js += "		e.preventDefault();\n"
#					js += "		var row = $(this).closest('tr');\n"
#					js += "		row.find('a.inline-edit.edit').hide();\n"
#					js += "		row.find('a.inline-edit.edit').parent('.btn').hide();\n"
#					js += "		row.find('.inline-edit.value').hide();\n"
#					js += "		row.find('a.inline-edit.save').show();\n"
#					js += "		row.find('a.inline-edit.save').parent('.btn').show();\n"
#					js += "		row.find('.inline-edit.field').show();\n"
#					js += "	});\n"#

#					js += "	$('#index-table-#{hash} a.inline-edit.save').on('click', function(e) {\n"
#					js += "		e.preventDefault();\n"
#					js += "		var _this = $(this);\n"
#					js += "		var row = _this.closest('tr');\n"
#					js += "		var url = _this.attr('href');\n"
#					js += "		$.ajax({\n"
#					js += "			url: url,\n"
#					js += "			dataType: 'json',\n"
#					js += "			type: 'PUT',\n"
#					js += "			data: row.find('input').serialize(),\n"
#					js += "			success: function(callback) \n"
#					js += "			{\n"
#					js += "				row.find('.inline-edit.field').removeClass('danger');\n"
#					js += "				if (callback === true) {\n"
#					js += "					row.find('.inline-edit.value').each(function () {\n"
#					js += "						$(this).html($(this).next().find('input').val());\n"
#					js += "					});\n"
#					js += "					row.find('a.inline-edit.save').hide();\n"
#					js += "					row.find('a.inline-edit.save').parent('.btn').hide();\n"
#					js += "					row.find('.inline-edit.field').hide();\n"
#					js += "					row.find('a.inline-edit.edit').show();\n"
#					js += "					row.find('a.inline-edit.edit').parent('.btn').show();\n"
#					js += "					row.find('.inline-edit.value').show();\n"
#					js += "				} else {\n"
#					js += "					for (var column in callback) {\n"
#					js += "						form.find('.field.' + column).addClass('danger');\n"
#					js += "					}\n"
#					js += "				}\n"
#					js += "				$(document).trigger('rug:index_table:inline_edit');\n"
#					js += "			},\n"
#					js += "			error: function(callback) \n"
#					js += "			{\n"
#					js += "				console.log('error');\n"
#					js += "			}\n"
#					js += "		});\n"
#					js += "	});\n"
#					js += "}\n"#

#					js += "$(document).ready(index_table_#{hash}_inline_edit_ready);\n"
#					js += "$(document).on('page:load', index_table_#{hash}_inline_edit_ready);\n"#

#					return @template.javascript_tag(js)
#				else
#					return ""
#				end
#			end#

#			def check_inline_edit(options, column = nil)
#				if column.nil?
#					return options[:paths] && options[:paths][:update] && options[:inline_edit]
#				else
#					return options[:paths] && options[:paths][:update] && options[:inline_edit] && (options[:inline_edit] == true || options[:inline_edit].include?(column.to_sym))
#				end
#			end#

#			def get_inline_edit_link(object, options)
#				result = ""
#				if !options[:label_edit].nil?
#					if options[:label_edit] != false
#						label_edit = options[:label_edit]
#					else
#						label_edit = ""
#					end
#				else
#					label_edit = I18n.t("general.action.edit")
#				end
#				if !options[:label_save].nil?
#					if options[:label_save] != false
#						label_save = options[:label_save]
#					else
#						label_save = ""
#					end
#				else
#					label_save = I18n.t("general.action.save")
#				end
#				link_tag_class = ""
#				if options[:disable_button] != true
#					link_tag_class = "btn btn-xs btn-primary"
#				end
#				result += @template.link_to(RugBuilder::IconBuilder.render("pencil") + label_edit, "#", class: "inline-edit edit " + link_tag_class)
#				result += @template.link_to(RugBuilder::IconBuilder.render("check") + label_save, RugSupport::PathResolver.new(@template).resolve(options[:paths][:update], object), class: "inline-edit save " + link_tag_class, style: "display: none;")
#				return result
#			end#

#			def get_inline_edit_field(object, column, value, model_class)
#				return "<input name=\"#{model_class.model_name.param_key}[#{column.to_s}]\" type=\"text\" class=\"text input\" value=\"#{value}\"/>"
#			end
			
		end
#	end
end