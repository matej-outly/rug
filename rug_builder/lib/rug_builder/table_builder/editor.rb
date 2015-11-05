# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - editor
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class TableBuilder

		#
		# Render editor table
		#
		# Options:
		# - paths (hash) - Define paths to create and destroy actions
		#
		def editor(objects, columns, data, options = {})

			# Model class
			model_class = get_model_class(objects, options)
			
			# Normalize columns to Columns object
			columns = normalize_columns(columns)

			# Table
			result = ""
			result += "<table class=\"editor_table striped #{options[:class].to_s}\">"

			# Table head
			result += "<thead>"
			result += "<tr>"
			columns.headers.each do |column|
				result += "<th>"
				result += model_class.human_attribute_name(column.to_s).upcase_first
				result += "</th>"
			end
			result += "<th></th>" if check_edit_link(options)
			result += "<th></th>"
			result += "</tr>"
			result += "</thead>"

			# Table body
			result += "<tbody>"
			objects.each do |object|
				result += "<tr class=\"#{object.new_record? ? "possibility" : ""}\">"
				columns.headers.each_with_index do |column, idx|
					if idx == 0 && check_show_link(options)
						result += "<td>#{get_show_link(object, columns.render(column, object), options)}</td>"
					else
						result += "<td>#{columns.render(column, object)}</td>"
					end
				end
				result += "<td>#{get_edit_link(object, options) if !object.new_record?}</td>" if check_edit_link(options)
				result += "<td>"
				if object.new_record? 

					# Create hidden fields containing create data
					data.each do |data_column|
						result += get_editor_create_field(object, data_column, object.send(data_column), model_class)
					end

					result += get_create_link(object, options) if check_create_link(options)
				else
					result += get_destroy_link(object, options, disable_method_and_notification: true) if check_destroy_link(options)
				end
				result += "</td>"
				result += "</tr>"
			end
			result += "</tbody>"

			# Table
			result += "</table>"

			# JS
			result += resolve_editor_js

			return result.html_safe
		end

		#
		# Render hierarchical editor table
		#
		# Options:
		# - paths (hash) - Define paths to create and destroy actions
		#
		def hierarchical_editor(objects, columns, data, options = {})

			# Model class
			model_class = get_model_class(objects, options)

			# Normalize columns to Columns object
			columns = normalize_columns(columns)

			# Hierarchical
			maximal_level = model_class.maximal_level 
			open_siblings = {}
			open_levels = {}

			# Table
			result = ""
			result += "<table class=\"hierarchical editor_table striped #{options[:class].to_s}\">"

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
			result += "<th></th>" if check_edit_link(options)
			result += "<th></th>"
			result += "</tr>"
			result += "</thead>"

			# Table body
			result += "<tbody>"
			idx = 0
			model_class.each_plus_dummy_with_level(objects) do |object, level|
				
				if !object.nil?
					
					# Node
					result += "<tr class=\"#{object.new_record? ? "possibility" : ""}\">"

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
					result += "<td>#{get_edit_link(object, options) if !object.new_record?}</td>" if check_edit_link(options)
					result += "<td>"
					if object.new_record? 

						# Create hidden fields containing create data
						data.each do |data_column|
							result += get_editor_create_field(object, data_column, object.send(data_column), model_class)
						end

						result += get_create_link(object, options) if check_create_link(options)
					else
						result += get_destroy_link(object, options, disable_method_and_notification: true) if check_destroy_link(options)
					end
					result += "</td>"
					result += "</tr>"

				end
				idx += 1
			end			
			result += "</tbody>"

			# Table
			result += "</table>"

			# JS
			result += resolve_editor_js

			return result.html_safe
		end
	
	protected

		def resolve_editor_js
			js = ''

			js += 'function editor_table_ready()'
			js += '{'
			js += '	$(".editor_table a.create").on("click", function(e) {'
			js += '		e.preventDefault();'
			js += '		var _this = $(this);'
			js += '		var row = _this.closest("tr");'
			js += '		var url = _this.attr("href");'
			js += '		$.ajax({'
			js += '			url: url,'
			js += '			dataType: "html",'
			js += '			type: "POST",'
			js += '			data: row.find("input").serialize(),'
			js += '			success: function(callback) '
			js += '			{'
			js += '				var new_html = $(callback).find(".editor_table").html();'
			js += '				$(".editor_table").html(new_html);'
			js += '				editor_table_ready();'
			js += '				$(document).trigger("rug:editor_table:create");'
			js += '			},'
			js += '			error: function(callback) '
			js += '			{'
			js += '				console.log("error");'
			js += '			}'
			js += '		});'
			js += '	});'

			js += '	$(".editor_table a.destroy").on("click", function(e) {'
			js += '		e.preventDefault();'
			js += '		var _this = $(this);'
			js += '		var url = _this.attr("href");'
			js += '		$.ajax({'
			js += '			url: url,'
			js += '			dataType: "html",'
			js += '			type: "DELETE",'
			js += '			success: function(callback) '
			js += '			{'
			js += '				var new_html = $(callback).find(".editor_table").html();'
			js += '				$(".editor_table").html(new_html);'
			js += '				editor_table_ready();'
			js += '				$(document).trigger("rug:editor_table:destroy");'
			js += '			},'
			js += '			error: function(callback) '
			js += '			{'
			js += '				console.log("error");'
			js += '			}'
			js += '		});'
			js += '	});'
			js += '}'

			js += '$(document).ready(editor_table_ready);'
			js += '$(document).on("page:load", editor_table_ready);'

			return @template.javascript_tag(js)
		end
		
		def get_editor_create_field(object, column, value, model_class)
			return "<input name=\"#{model_class.model_name.param_key}[#{column.to_s}]\" type=\"hidden\" value=\"#{value}\"/>"
		end

	end
end