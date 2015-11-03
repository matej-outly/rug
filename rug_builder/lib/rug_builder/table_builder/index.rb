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

			# Table
			result = ""
			if options[:page_break] && options[:page_break] > 0 # Sliced
				objects.each_slice(options[:page_break]) do |slice|
					result += index_body(slice, columns, model_class, options)
				end
			else # Not slices
				result += index_body(objects, columns, model_class, options)
			end

			# Pagination
			result += resolve_pagination(objects, options)
			
			# Summary
			result += resolve_summary(objects, model_class, options)

			# Inline edit JS
			result += resolve_inline_edit_js(options)

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
				result += "<table class=\"hierarchical index_table striped #{options[:class].to_s}\">"

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
						result += "<tr>"

						# Nesting 
						open_siblings[level] = false 
						open_levels[level] = object.id
						
						(0..level-1).each do |zero_level|
							if open_siblings[zero_level] == true
								result += "<td class=\"nesting nesting_0_inner\"></td>"
							else
								result += "<td class=\"nesting nesting_0_none\"></td>"
							end
						end
						if object.right_sibling == nil
							result += "<td class=\"nesting nesting_1_nosibling\"></td>"
						else
							open_siblings[level] = true
							result += "<td class=\"nesting nesting_1_sibling\"></td>"
						end
						if object.leaf?
							result += "<td class=\"nesting nesting_2_nochild\"></td>"
						else
							result += "<td class=\"nesting nesting_2_child\"></td>"
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
								result += "<td>#{get_action_link(object, action_spec)}</td>"
							end
						end
						result += "<td>#{get_edit_link(object, options)}</td>" if check_edit_link(options)
						result += "<td>#{get_destroy_link(object, options)}</td>" if check_destroy_link(options)
						result += "</tr>"

					end
					idx += 1
				end			
				result += "</tbody>"

				# Table
				result += "</table>"

			end 
			
			# Summary
			result += resolve_summary(objects, model_class, options)

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
				return "<div class=\"flash warning alert\">#{ I18n.t("views.index_table.empty") }</div>"
			else 
				result = ""
				result += "<div class=\"picture index_table\">"
				objects.each do |object|
					result += "<div class=\"item\">"
					columns.headers.each_with_index do |column, idx|
						
						# Standard read only value
						if idx == 0 && check_show_link(options)
							result += "<div class=\"picture\">#{get_show_link(object, columns.render(column, object), options)}</div>"
						else
							result += "<div class=\"description\">#{columns.render(column, object)}</div>"
						end

					end
					result += "<div class=\"edit\">#{get_edit_link(object, options)}</div>" if check_edit_link(options)
					result += "<div class=\"destroy\">#{get_destroy_link(object, options)}</div>" if check_destroy_link(options)
					result += "</div>"
				end
				result += "</div>"
			end

			# Pagination
			result += resolve_pagination(objects, options)
			
			# Summary
			result += resolve_summary(objects, model_class, options)

			return result.html_safe
		end

	protected

		def index_body(objects, columns, model_class, options)

			if objects.empty?
				return "<div class=\"flash warning alert\">#{ I18n.t("views.index_table.empty") }</div>"
			end

			# Table
			result = ""
			result += "<table class=\"index_table striped #{options[:class].to_s}\">"

			# Table head
			result += "<thead>"
			result += "<tr>"
			columns.headers.each do |column|
				result += "<th>"
				result += model_class.human_attribute_name(column.to_s).upcase_first
				result += resolve_sorting(column, options)
				result += "</th>"
			end
			if options[:actions]
				options[:actions].each do |action, action_spec|
					result += "<th></th>"
				end
			end
			result += "<th></th>" if check_inline_edit(options)
			result += "<th></th>" if check_edit_link(options)
			result += "<th></th>" if check_destroy_link(options)
			result += "</tr>"
			result += "</thead>"

			# Table body
			result += "<tbody>"
			objects.each do |object|
				
				result += "<tr>"
				columns.headers.each_with_index do |column, idx|
					result += "<td>"
					if check_inline_edit(options, column)
						result += "<div class=\"inline_edit value\">"
					end

					# Standard read only value
					if idx == 0 && check_show_link(options)
						result += get_show_link(object, columns.render(column, object), options)
					else
						result += columns.render(column, object)
					end
					
					if check_inline_edit(options, column)
						result += "</div>"
						result += "<div class=\"inline_edit field\" style=\"display: none;\">#{get_inline_edit_field(object, column, columns.render(column, object), model_class)}</div>"
					end
					result += "</td>"
				end
				if options[:actions]
					options[:actions].each do |action, action_spec|
						result += "<td>#{get_action_link(object, action_spec)}</td>"
					end
				end
				result += "<td>#{get_inline_edit_link(object, options)}</td>" if check_inline_edit(options)
				result += "<td>#{get_edit_link(object, options)}</td>" if check_edit_link(options)
				result += "<td>#{get_destroy_link(object, options)}</td>" if check_destroy_link(options)
				result += "</tr>"

			end
			result += "</tbody>"

			# Table
			result += "</table>"

			return result
		end

		# *********************************************************************
		# Common actions
		# *********************************************************************

		def get_action_link(object, spec)
			url = RugSupport::PathResolver.new(@template).resolve(spec[:path], object)
			return @template.link_to("<i class=\"icon-#{spec[:icon]}\"></i>".html_safe + spec[:label], url)
		end

		# *********************************************************************
		# Inline editation
		# *********************************************************************

		def resolve_inline_edit_js(options)
			if check_inline_edit(options)

				js = ''
				js += 'function index_table_inline_edit_ready()'
				js += '{'
				js += '	$(".index_table a.inline_edit.edit").on("click", function(e) {'
				js += '		e.preventDefault();'
				js += '		var row = $(this).closest("tr");'
				js += '		row.find("a.inline_edit.edit").hide();'
				js += '		row.find(".inline_edit.value").hide();'
				js += '		row.find("a.inline_edit.save").show();'
				js += '		row.find(".inline_edit.field").show();'
				js += '	});'

				js += '	$(".index_table a.inline_edit.save").on("click", function(e) {'
				js += '		e.preventDefault();'
				js += '		var _this = $(this);'
				js += '		var row = _this.closest("tr");'
				js += '		var url = _this.attr("href");'
				js += '		$.ajax({'
				js += '			url: url,'
				js += '			dataType: "json",'
				js += '			type: "PUT",'
				js += '			data: row.find("input").serialize(),'
				js += '			success: function(callback) '
				js += '			{'
				js += '				row.find(".inline_edit.field").removeClass("danger");'
				js += '				if (callback === true) {'
				js += '					row.find(".inline_edit.value").each(function () {'
				js += '						$(this).html($(this).next().find("input").val());'
				js += '					});'
				js += '					row.find("a.inline_edit.save").hide();'
				js += '					row.find(".inline_edit.field").hide();'
				js += '					row.find("a.inline_edit.edit").show();'
				js += '					row.find(".inline_edit.value").show();'
				js += '				} else {'
				js += '					for (var column in callback) {'
				js += '						form.find(".field." + column).addClass("danger");'
				js += '					}'
				js += '				}'
				js += '				$(document).trigger("rug:index_table:inline_edit");'
				js += '			},'
				js += '			error: function(callback) '
				js += '			{'
				js += '				console.log("error");'
				js += '			}'
				js += '		});'
				js += '	});'
				js += '}'

				js += '$(document).ready(index_table_inline_edit_ready);'
				js += '$(document).on("page:load", index_table_inline_edit_ready);'

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
		
	end
end