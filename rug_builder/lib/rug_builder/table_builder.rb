# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

require "rug_builder/table_builder/columns"

module RugBuilder
	class TableBuilder
		
		#
		# Constructor
		#
		def initialize(template)
			@template = template
		end

		#
		# Render show table
		#
		def show(object, columns)

			# Check
			if object.nil?
				raise "Given object is nil."
			end

			result = ""

			# Normalize columns to Columns object
			columns = normalize_columns(columns)

			# Headers
			columns_headers = columns.headers

			# Table
			result += "<table class=\"show_table\">"

			# Table body
			result += "<tbody>"
			columns_headers.each do |column|
				result += "<tr>"
				result += "<td>#{object.class.human_attribute_name(column.to_s).upcase_first}</td>"
				result += "<td>#{columns.render(column, object)}</td>"
				result += "</tr>"
			end
			result += "</tbody>"

			# Table
			result += "</table>"

			return result.html_safe
		end

		#
		# Render index table
		#
		# Options:
		# - paths (hash) - Define paths to show, edit and destroy actions
		# - pagination (boolean) - Turn on pagination
		# - sorting (boolean or hash) - Turn on sorting, can be specified which columns are suitable for sorting
		# - summary (boolean) - Turn on summary
		#
		def index(objects, columns, options = {})

			result = ""

			# Model class
			model_class = get_model_class(objects, options)

			# Normalize columns
			columns = normalize_columns(columns)

			# Headers
			columns_headers = columns.headers

			# Table
			result += "<table class=\"index_table striped\">"

			# Table head
			result += "<thead>"
			result += "<tr>"
			columns_headers.each do |column|
				result += "<th>"
				result += model_class.human_attribute_name(column.to_s).upcase_first
				result += resolve_sorting(column, options)
				result += "</th>"
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
				columns_headers.each_with_index do |column, idx|
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
				result += "<td>#{get_inline_edit_links(object, options)}</td>" if check_inline_edit(options)
				result += "<td>#{get_edit_link(object, options)}</td>" if check_edit_link(options)
				result += "<td>#{get_destroy_link(object, options)}</td>" if check_destroy_link(options)
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

				result += @template.javascript_tag(js)
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

			result = ""

			# Model class
			model_class = get_model_class(objects, options)

			# Normalize columns to Columns object
			columns = normalize_columns(columns)

			# Headers
			columns_headers = columns.headers

			# Hierarchical
			maximal_level = model_class.maximal_level 
			open_siblings = {}
			open_levels = {}

			# Table
			result += "<table class=\"hierarchical index_table striped\">"

			# Table head
			result += "<thead>"
			result += "<tr>"
			result += "<th colspan=\"2\">#{ I18n.t("general.nesting").upcase_first }</th>"
			columns_headers.each_with_index do |column, idx|
				if idx == 0
					result += "<th colspan=\"#{ maximal_level + 1 }\">#{ model_class.human_attribute_name(column.to_s).upcase_first }</th>"
				else
					result += "<th>#{ model_class.human_attribute_name(column.to_s).upcase_first }</th>"
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
					columns_headers.each_with_index do |column, column_idx|
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
					result += "<td>#{get_edit_link(object, options)}</td>" if check_edit_link(options)
					result += "<td>#{get_destroy_link(object, options)}</td>" if check_destroy_link(options)
					result += "</tr>"

				end
				idx += 1
			end			
			result += "</tbody>"

			# Table
			result += "</table>"

			# Summary
			result += resolve_summary(objects, model_class, options)

			return result.html_safe
		end

		#
		# Render editor table
		#
		# Options:
		# - paths (hash) - Define paths to create and destroy actions
		#
		def editor(objects, columns, data, options = {})

			result = ""

			# Model class
			model_class = get_model_class(objects, options)
			
			# Normalize columns to Columns object
			columns = normalize_columns(columns)

			# Headers
			columns_headers = columns.headers

			# Table
			result += "<table class=\"editor_table striped\">"

			# Table head
			result += "<thead>"
			result += "<tr>"
			columns_headers.each do |column|
				result += "<th>"
				result += model_class.human_attribute_name(column.to_s).upcase_first
				result += "</th>"
			end
			result += "<th></th>"
			result += "</tr>"
			result += "</thead>"

			# Table body
			result += "<tbody>"
			objects.each do |object|
				result += "<tr class=\"#{object.new_record? ? "possibility" : ""}\">"
				columns_headers.each_with_index do |column, idx|
					if idx == 0 && check_show_link(options)
						result += "<td>#{get_show_link(object, columns.render(column, object), options)}</td>"
					else
						result += "<td>#{columns.render(column, object)}</td>"
					end
				end
				result += "<td>"
				if object.new_record? 
					result += get_create_link(object, options) if check_create_link(options)
				else
					result += get_destroy_link(object, options) if check_destroy_link(options)
				end
				result += "</td>"
				result += "</tr>"
			end
			result += "</tbody>"

			# Table
			result += "</table>"

			return result.html_safe
		end

		#
		# Render hierarchical editor table
		#
		# Options:
		# - paths (hash) - Define paths to create and destroy actions
		#
		def hierarchical_editor(objects, columns, data, options = {})

			result = ""

			# Model class
			model_class = get_model_class(objects, options)

			# Normalize columns to Columns object
			columns = normalize_columns(columns)

			# Headers
			columns_headers = columns.headers

			# Hierarchical
			maximal_level = model_class.maximal_level 
			open_siblings = {}
			open_levels = {}

			# Table
			result += "<table class=\"hierarchical editor_table striped\">"

			# Table head
			result += "<thead>"
			result += "<tr>"
			result += "<th colspan=\"2\">#{ I18n.t("general.nesting").upcase_first }</th>"
			columns_headers.each_with_index do |column, idx|
				if idx == 0
					result += "<th colspan=\"#{ maximal_level + 1 }\">#{ model_class.human_attribute_name(column.to_s).upcase_first }</th>"
				else
					result += "<th>#{ model_class.human_attribute_name(column.to_s).upcase_first }</th>"
				end
			end
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
					columns_headers.each_with_index do |column, column_idx|
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
					result += "<td>"
					if object.new_record? 
						result += get_create_link(object, options) if check_create_link(options)
					else
						result += get_destroy_link(object, options) if check_destroy_link(options)
					end
					result += "</td>"
					result += "</tr>"

				end
				idx += 1
			end			
			result += "</tbody>"

			# Table
			result += "</table>"

			return result.html_safe
		end

	private

		def get_model_class(objects, options)
			
			# Model class
			if options[:model_class]
				model_class = options[:model_class].constantize
			else
				model_class = objects.class.to_s.deconstantize
				if !model_class.blank?
					model_class = model_class.constantize
				end
			end
			if model_class.blank?
				raise "Please supply model class to options or use ActiveRecord::Relation as collection."
			end

			return model_class
		end

		def normalize_columns(columns)
			columns = Columns.new(columns) if !columns.is_a? Columns
			columns.template = @template
			return columns
		end

		def resolve_pagination(objects, options)
			if options[:pagination] == true
				return @template.paginate(objects)
			else
				return ""
			end
		end

		def resolve_summary(objects, model_class, options)
			if options[:summary] == true
				return "<div class=\"summary\">#{I18n.t("general.shown").upcase_first}: #{objects.length}#{(model_class.respond_to?(:count) ? ("/" + model_class.count.to_s) : "")}</div>"
			else
				return ""
			end
		end

		def resolve_sorting(column, options)
			result = ""
			if options[:sorting] 
				if options[:sorting] == true
					result = " <span class=\"sorting\">" + @template.link_to(I18n.t("general.action.sort"), sort: column.to_s, page: @template.params[:page]) + "</span>"
				elsif options[:sorting][column.to_sym]
					result = " <span class=\"sorting\">" + @template.link_to(I18n.t("general.action.sort"), sort: (options[:sorting][column.to_sym] == true ? column.to_s : options[:sorting][column.to_sym].to_s), page: @template.params[:page]) + "</span>"
				end
			end
			return result
		end

		def check_destroy_link(options)
			return options[:paths] && options[:paths][:destroy]
		end

		def get_destroy_link(object, options)
			return @template.link_to "<i class=\"icon-trash\"></i>".html_safe + I18n.t("general.action.destroy"), (options[:paths][:destroy].is_a?(Proc) ? options[:paths][:destroy].call(object) : @template.method(options[:paths][:destroy]).call(object)), method: :delete, class: "destroy", data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") }
		end
		
		def check_edit_link(options)
			return options[:paths] && options[:paths][:edit]
		end

		def get_edit_link(object, options)
			return @template.link_to "<i class=\"icon-pencil\"></i>".html_safe + I18n.t("general.action.edit"), (options[:paths][:edit].is_a?(Proc) ? options[:paths][:edit].call(object) : @template.method(options[:paths][:edit]).call(object)), class: "edit"
		end

		def check_show_link(options)
			return options[:paths] && options[:paths][:show]
		end

		def get_show_link(object, label, options)
			return @template.link_to label, (options[:paths][:show].is_a?(Proc) ? options[:paths][:show].call(object) : @template.method(options[:paths][:show]).call(object))
		end

		def check_create_link(options)
			return options[:paths] && options[:paths][:create]
		end

		def get_create_link(object, options)
			return @template.link_to "<i class=\"icon-plus\"></i>".html_safe + I18n.t("general.action.create"), (options[:paths][:create].is_a?(Proc) ? options[:paths][:create].call : @template.method(options[:paths][:create]).call), class: "create"
		end

		def check_inline_edit(options, column = nil)
			if column.nil?
				return options[:paths] && options[:paths][:update] && options[:inline_edit]
			else
				return options[:paths] && options[:paths][:update] && options[:inline_edit] && (options[:inline_edit] == true || options[:inline_edit].include?(column.to_sym))
			end
		end

		def get_inline_edit_links(object, options)
			result = ""
			result += @template.link_to "<i class=\"icon-pencil\"></i>".html_safe + I18n.t("general.action.edit"), "#", class: "inline_edit edit"
			result += @template.link_to "<i class=\"icon-check\"></i>".html_safe + I18n.t("general.action.save"), (options[:paths][:update].is_a?(Proc) ? options[:paths][:update].call(object) : @template.method(options[:paths][:update]).call(object)), class: "inline_edit save", style: "display: none;"
			return result
		end

		def get_inline_edit_field(object, column, value, model_class)
			return "<input name=\"#{model_class.model_name.param_key}[#{column.to_s}]\" type=\"text\" class=\"text input\" value=\"#{value}\"/>"
		end

	end
end
