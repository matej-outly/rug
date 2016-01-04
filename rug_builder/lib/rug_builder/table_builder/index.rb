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
	class TableBuilder

		#
		# Render index table
		#
		# Options:
		# - paths (hash) - Define paths to show, edit, inline_edit (update) and destroy actions
		# - pagination (boolean) - Turn on pagination
		# - sorting (boolean or hash) - Turn on sorting, can be specified which columns are suitable for sorting
		# - summary (boolean) - Turn on summary
		# - inline_edit (array) - array of columns suitable for inline edit
		# - page_break (integer) - Break table (and page) after given number of rows
		#
		def index(objects, columns, options = {})

			# Model class
			model_class = get_model_class(objects, options)

			# Normalize columns
			columns = normalize_columns(columns)

			if objects.empty?
				result = "<div class=\"flash warning alert\">#{ I18n.t("views.index_table.empty") }</div>"
			else

				# Table
				result = ""
				result += "<table class=\"index-table #{(check_moving(options) ? "moving" : "")} #{options[:class].to_s}\">"

				# Table head
				columns_count = 0
				result += "<thead>"
				result += "<tr>"
				if check_moving(options)
					result += "<th></th>" 
					columns_count += 1
				end
				columns.headers.each do |column|
					result += "<th>"
					result += model_class.human_attribute_name(column.to_s).upcase_first
					result += resolve_sorting(column, options)
					result += "</th>"
					columns_count += 1
				end
				if options[:actions]
					options[:actions].each do |action, action_spec|
						result += "<th></th>"
						columns_count += 1
					end
				end
				if check_inline_edit(options)
					result += "<th></th>"
					columns_count += 1
				end
				if check_edit_link(options)
					result += "<th></th>"
					columns_count += 1
				end
				if check_destroy_link(options)
					result += "<th></th>" 
					columns_count += 1
				end
				result += "</tr>"
				result += "</thead>"

				# Table body
				result += "<tbody>"
				objects.each do |object|
					
					result += "<tr data-id=\"#{object.id}\">"
					result += "<td class=\"action\">#{get_moving_link}</td>" if check_moving(options)
					columns.headers.each_with_index do |column, idx|
						result += "<td>"
						if check_inline_edit(options, column)
							result += "<div class=\"inline-edit value\">"
						end

						# Standard read only value
						if idx == 0 && check_show_link(options)
							result += get_show_link(object, columns.render(column, object), options)
						else
							result += columns.render(column, object)
						end
						
						if check_inline_edit(options, column)
							result += "</div>"
							result += "<div class=\"inline-edit field\" style=\"display: none;\">#{get_inline_edit_field(object, column, columns.render(column, object), model_class)}</div>"
						end
						result += "</td>"
					end
					if options[:actions]
						options[:actions].each do |action, action_spec|
							result += "<td class=\"action\">#{get_action_link(object, action_spec)}</td>"
						end
					end
					result += "<td class=\"action\">#{get_inline_edit_link(object, options)}</td>" if check_inline_edit(options)
					result += "<td class=\"action\">#{get_edit_link(object, options, label: false)}</td>" if check_edit_link(options)
					result += "<td class=\"action\">#{get_destroy_link(object, options, label: false)}</td>" if check_destroy_link(options)
					result += "</tr>"

				end
				result += "</tbody>"

				# Table
				result += "</table>"
			
				# Pagination
				result += resolve_pagination(objects, options)
				
				# Summary
				result += resolve_summary(objects, model_class, options)

				# Inline edit JS
				result += resolve_inline_edit_js(options)

				# Moving JS
				result += resolve_moving_js(columns_count, options)

			end

			return result.html_safe
		end

		#
		# Render hierarchical index table
		#
		# Options:
		# - paths (hash) - Define paths to show, edit and destroy actions
		# - summary (boolean) - Turn on summary
		#
		def hierarchical_index(objects, columns, options = {})

			# Model class
			model_class = get_model_class(objects, options)

			# Normalize columns to Columns object
			columns = normalize_columns(columns)

			# Hierarchical
			maximal_level = model_class.maximal_level 
			open_siblings = {}
			open_levels = {}

			if objects.empty?
				result = "<div class=\"flash warning alert\">#{ I18n.t("views.index_table.empty") }</div>"
			else

				# Table
				result = ""
				result += "<table class=\"hierarchical index-table #{options[:class].to_s}\">"

				# Table head
				result += "<thead>"
				result += "<tr>"
				result += "<th colspan=\"2\">#{ I18n.t("general.nesting").upcase_first }</th>"
				columns.headers.each_with_index do |column, idx|
					if idx == 0
						result += "<th colspan=\"#{ maximal_level + 1 }\">#{ model_class.human_attribute_name(column.to_s).upcase_first }</th>"
					else
						result += "<th>#{ model_class.human_attribute_name(column.to_s).upcase_first }</th>"
					end
				end
				if options[:actions]
					options[:actions].each do |action, action_spec|
						result += "<th></th>"
					end
				end
				result += "<th></th>" if check_edit_link(options)
				result += "<th></th>" if check_destroy_link(options)
				result += "</tr>"
				result += "</thead>"

				# Table body
				result += "<tbody>"
				idx = 0
				model_class.each_plus_dummy_with_level(objects) do |object, level|
					
					if !object.nil?
						
						# Node
						result += "<tr data-id=\"#{object.id}\">"

						# Nesting 
						open_siblings[level] = false 
						open_levels[level] = object.id
						
						(0..level-1).each do |zero_level|
							if open_siblings[zero_level] == true
								result += "<td class=\"nesting nesting-0-inner\"></td>"
							else
								result += "<td class=\"nesting nesting-0-none\"></td>"
							end
						end
						if object.right_sibling == nil
							result += "<td class=\"nesting nesting-1-nosibling\"></td>"
						else
							open_siblings[level] = true
							result += "<td class=\"nesting nesting-1-sibling\"></td>"
						end
						if object.leaf?
							result += "<td class=\"nesting nesting-2-nochild\"></td>"
						else
							result += "<td class=\"nesting nesting-2-child\"></td>"
						end

						# Columns
						columns.headers.each_with_index do |column, column_idx|
							if column_idx == 0
								if check_show_link(options)
									result += "<td class=\"leaf\" colspan=\"#{ (maximal_level + 1 - level) }\">#{get_show_link(object, columns.render(column, object), options)}</td>"
								else
									result += "<td class=\"leaf\" colspan=\"#{ (maximal_level + 1 - level) }\">#{columns.render(column, object)}</td>"
								end
							else
								result += "<td>#{columns.render(column, object)}</td>"
							end
						end

						# Actions
						if options[:actions]
							options[:actions].each do |action, action_spec|
								result += "<td class=\"action\">#{get_action_link(object, action_spec)}</td>"
							end
						end
						result += "<td class=\"action\">#{get_edit_link(object, options, label: false)}</td>" if check_edit_link(options)
						result += "<td class=\"action\">#{get_destroy_link(object, options, label: false)}</td>" if check_destroy_link(options)
						result += "</tr>"

					end
					idx += 1
				end			
				result += "</tbody>"

				# Table
				result += "</table>"

				# Summary
				result += resolve_summary(objects, model_class, options)

			end

			return result.html_safe
		end

		#
		# Render picture index table
		#
		# Options:
		# - paths (hash) - Define paths to show, edit and destroy actions
		# - pagination (boolean) - Turn on pagination
		# - summary (boolean) - Turn on summary
		#
		def picture_index(objects, columns, options = {})
			
			# Model class
			model_class = get_model_class(objects, options)

			# Normalize columns
			columns = normalize_columns(columns)

			# Table
			if objects.empty?
				result = "<div class=\"flash warning alert\">#{ I18n.t("views.index_table.empty") }</div>"
			else 
				result = ""
				result += "<div class=\"picture index-table\">"
				objects.each do |object|
					result += "<div class=\"item\" data-id=\"#{object.id}\">"
					columns.headers.each_with_index do |column, idx|
						
						# Standard read only value
						if idx == 0 && check_show_link(options)
							result += "<div class=\"picture\">#{get_show_link(object, columns.render(column, object), options, disable_button: true)}</div>"
						else
							result += "<div class=\"description\">#{columns.render(column, object)}</div>"
						end

					end
					result += "<div class=\"action edit\">#{get_edit_link(object, options, disable_button: true)}</div>" if check_edit_link(options)
					result += "<div class=\"action destroy\">#{get_destroy_link(object, options, disable_button: true)}</div>" if check_destroy_link(options)
					result += "</div>"
				end
				result += "</div>"

				# Pagination
				result += resolve_pagination(objects, options)
				
				# Summary
				result += resolve_summary(objects, model_class, options)

			end
			
			return result.html_safe
		end

	protected

		# *********************************************************************
		# Common actions
		# *********************************************************************

		def get_action_link(object, link_options)
			url = RugSupport::PathResolver.new(@template).resolve(link_options[:path], object)
			if url
				return "<div class=\"medium default btn icon-left entypo icon-#{link_options[:icon]}\">#{@template.link_to(link_options[:label], url)}</div>"
			else
				return ""
			end
		end

		# *********************************************************************
		# Inline editation
		# *********************************************************************

		def resolve_inline_edit_js(options)
			if check_inline_edit(options)

				js = ""
				js += "function index_table_inline_edit_ready()\n"
				js += "{\n"
				js += "	$('.index-table a.inline-edit.edit').on('click', function(e) {\n"
				js += "		e.preventDefault();\n"
				js += "		var row = $(this).closest('tr');\n"
				js += "		row.find('a.inline-edit.edit').hide();\n"
				js += "		row.find('.inline-edit.value').hide();\n"
				js += "		row.find('a.inline-edit.save').show();\n"
				js += "		row.find('.inline-edit.field').show();\n"
				js += "	});\n"

				js += "	$('.index-table a.inline-edit.save').on('click', function(e) {\n"
				js += "		e.preventDefault();\n"
				js += "		var _this = $(this);\n"
				js += "		var row = _this.closest('tr');\n"
				js += "		var url = _this.attr('href');\n"
				js += "		$.ajax({\n"
				js += "			url: url,\n"
				js += "			dataType: 'json',\n"
				js += "			type: 'PUT',\n"
				js += "			data: row.find('input').serialize(),\n"
				js += "			success: function(callback) \n"
				js += "			{\n"
				js += "				row.find('.inline-edit.field').removeClass('danger');\n"
				js += "				if (callback === true) {\n"
				js += "					row.find('.inline-edit.value').each(function () {\n"
				js += "						$(this).html($(this).next().find('input').val());\n"
				js += "					});\n"
				js += "					row.find('a.inline-edit.save').hide();\n"
				js += "					row.find('.inline-edit.field').hide();\n"
				js += "					row.find('a.inline-edit.edit').show();\n"
				js += "					row.find('.inline-edit.value').show();\n"
				js += "				} else {\n"
				js += "					for (var column in callback) {\n"
				js += "						form.find('.field.' + column).addClass('danger');\n"
				js += "					}\n"
				js += "				}\n"
				js += "				$(document).trigger('rug:index_table:inline_edit');\n"
				js += "			},\n"
				js += "			error: function(callback) \n"
				js += "			{\n"
				js += "				console.log('error');\n"
				js += "			}\n"
				js += "		});\n"
				js += "	});\n"
				js += "}\n"

				js += "$(document).ready(index_table_inline_edit_ready);\n"
				js += "$(document).on('page:load', index_table_inline_edit_ready);\n"

				return @template.javascript_tag(js)
			else
				return ""
			end
		end

		def check_inline_edit(options, column = nil)
			if column.nil?
				return options[:paths] && options[:paths][:update] && options[:inline_edit]
			else
				return options[:paths] && options[:paths][:update] && options[:inline_edit] && (options[:inline_edit] == true || options[:inline_edit].include?(column.to_sym))
			end
		end

		def get_inline_edit_link(object, options)
			result = ""
			result += @template.link_to("<i class=\"icon-pencil\"></i>".html_safe + I18n.t("general.action.edit"), "#", class: "inline_edit edit")
			result += @template.link_to("<i class=\"icon-check\"></i>".html_safe + I18n.t("general.action.save"), RugSupport::PathResolver.new(@template).resolve(options[:paths][:update], object), class: "inline_edit save", style: "display: none;")
			return result
		end

		def get_inline_edit_field(object, column, value, model_class)
			return "<input name=\"#{model_class.model_name.param_key}[#{column.to_s}]\" type=\"text\" class=\"text input\" value=\"#{value}\"/>"
		end

		# *********************************************************************
		# Moving
		# *********************************************************************

		def resolve_moving_js(columns_count, options)
			if check_moving(options)

				js = ""
				js += "function index_table_moving_ready()\n"
				js += "{\n"
				js += "	$('.index-table.moving').sortable({\n"
				js += "		containerSelector: 'table',\n"
				js += "		itemPath: '> tbody',\n"
				js += "		itemSelector: 'tr',\n"
				js += "		placeholder: '<tr class=\"placeholder\">#{"<td></td>" * columns_count}</tr>',\n"
				js += "		handle: '.moving-handle',\n"
				js += "		onDrop: function ($item, container, _super, event) {\n"
				js += "			$item.removeClass(container.group.options.draggedClass).removeAttr('style');\n"
				js += "			$('body').removeClass(container.group.options.bodyClass);\n"
				js += "			var id = $item.data('id');\n"
				js += "			var prev_id = $item.prev().data('id') ? $item.prev().data('id') : undefined;\n"
				js += "			var next_id = $item.next().data('id') ? $item.next().data('id') : undefined;\n"
				js += "			if (prev_id || next_id) {\n"
				js += "				var destination_id = prev_id;\n"
				js += "				var relation = 'succ';\n"
				js += "				if (!destination_id) {\n"
				js += "					destination_id = next_id;\n"
				js += "					relation = 'pred';\n"
				js += "				}\n"
				js += "				var move_url = '#{RugSupport::PathResolver.new(@template).resolve(options[:paths][:move], ":id", ":relation", ":destination_id")}'.replace(':id', id).replace(':relation', relation).replace(':destination_id', destination_id);\n"
				js += "				$.ajax({url: move_url, method: 'PUT', dataType: 'json'});" # TODO check response for TRUE
				js += "			}\n" # Else unable to move
				js += "		}\n"
				js += "	});\n"
				js += "}\n"

				js += "$(document).ready(index_table_moving_ready);\n"
				js += "$(document).on('page:load', index_table_moving_ready);\n"

				return @template.javascript_tag(js)
			else
				return ""
			end
		end

		def check_moving(options)
			return options[:moving] == true && options[:paths] && options[:paths][:move]
		end

		def get_moving_link
			return "<div class=\"medium default btn icon-left entypo icon-arrow-combo moving-handle\"><a href=\"#\"></a></div>"
		end
		
	end
end