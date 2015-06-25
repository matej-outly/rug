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
			model_class = collection_model_class(objects, options)

			# Normalize columns to Columns object
			columns = Columns.new(columns) if !columns.is_a? Columns
			columns.template = @template

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
				
				# Sorting
				# --------
				if options[:sorting] 
					if options[:sorting] == true
						result += " <span class=\"sorting\">" + @template.link_to(I18n.t("general.action.sort"), sort: column.to_s, page: @template.params[:page]) + "</span>"
					elsif options[:sorting][column.to_sym]
						result += " <span class=\"sorting\">" + @template.link_to(I18n.t("general.action.sort"), sort: (options[:sorting][column.to_sym] == true ? column.to_s : options[:sorting][column.to_sym].to_s), page: @template.params[:page]) + "</span>"
					end
				end
				
				result += "</th>"
			end
			result += "<th></th>" if options[:paths] && options[:paths][:edit]
			result += "<th></th>" if options[:paths] && options[:paths][:destroy]	
			result += "</tr>"
			result += "</thead>"

			# Table body
			result += "<tbody>"
			objects.each do |object|
				result += "<tr>"
				columns_headers.each_with_index do |column, idx|
					if idx == 0 && options[:paths] && options[:paths][:show]
						result += "<td>#{@template.link_to columns.render(column, object), @template.method(options[:paths][:show]).call(object)}</td>"
					else
						result += "<td>#{columns.render(column, object)}</td>"
					end
				end
				result += "<td>#{@template.link_to "<i class=\"icon-pencil\"></i>".html_safe + I18n.t("general.action.edit"), @template.method(options[:paths][:edit]).call(object)}</td>" if options[:paths] && options[:paths][:edit]
				result += "<td>#{@template.link_to "<i class=\"icon-trash\"></i>".html_safe + I18n.t("general.action.destroy"), @template.method(options[:paths][:destroy]).call(object), method: :delete, data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") }}</td>" if options[:paths] && options[:paths][:destroy]
				result += "</tr>"
			end
			result += "</tbody>"

			# Table
			result += "</table>"

			# Pagination
			# ----------
			
			if options[:pagination] == true
				result += @template.paginate(objects)
			end

			# Summary
			# -------

			if options[:summary] == true
				result += "<div class=\"summary\">#{I18n.t("general.shown").upcase_first}: #{objects.length}#{(model_class.respond_to?(:count) ? ("/" + model_class.count.to_s) : "")}</div>"
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
			model_class = collection_model_class(objects, options)

			# Normalize columns to Columns object
			columns = Columns.new(columns) if !columns.is_a? Columns
			columns.template = @template

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
			result += "<th></th>" if options[:paths] && options[:paths][:edit]
			result += "<th></th>" if options[:paths] && options[:paths][:destroy]	
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
							if options[:paths] && options[:paths][:show]
								result += "<td class=\"leaf\" colspan=\"#{ (maximal_level + 1 - level) }\">#{@template.link_to columns.render(column, object), @template.method(options[:paths][:show]).call(object)}</td>"
							else
								result += "<td class=\"leaf\" colspan=\"#{ (maximal_level + 1 - level) }\">#{columns.render(column, object)}</td>"
							end
						else
							result += "<td>#{columns.render(column, object)}</td>"
						end
					end

					# Actions
					result += "<td>#{@template.link_to "<i class=\"icon-pencil\"></i>".html_safe + I18n.t("general.action.edit"), @template.method(options[:paths][:edit]).call(object)}</td>" if options[:paths] && options[:paths][:edit]
					result += "<td>#{@template.link_to "<i class=\"icon-trash\"></i>".html_safe + I18n.t("general.action.destroy"), @template.method(options[:paths][:destroy]).call(object), method: :delete, data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") }}</td>" if options[:paths] && options[:paths][:destroy]
					result += "</tr>"

				end
				idx += 1
			end			
			result += "</tbody>"

			# Table
			result += "</table>"

			# Summary
			# -------

			if options[:summary] == true
				result += "<div class=\"summary\">#{I18n.t("general.shown").upcase_first}: #{objects.length}#{(model_class.respond_to?(:count) ? ("/" + model_class.count.to_s) : "")}</div>"
			end

			return result.html_safe
		end

		#
		# Render show table
		#
		def show(object, columns)

			result = ""

			# Normalize columns to Columns object
			columns = Columns.new(columns) if !columns.is_a? Columns
			columns.template = @template

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
		# Render editor table
		#
		# Options:
		# - paths (hash) - Define paths to create and destroy actions
		#
		def editor(objects, columns, data, options = {})

			result = ""

			# Model class
			model_class = collection_model_class(objects, options)
			
			# Normalize columns to Columns object
			columns = Columns.new(columns) if !columns.is_a? Columns
			columns.template = @template

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
					if idx == 0 && options[:paths] && options[:paths][:show]
						result += "<td>#{@template.link_to columns.render(column, object), @template.method(options[:paths][:show]).call(object)}</td>"
					else
						result += "<td>#{columns.render(column, object)}</td>"
					end
				end
				result += "<td>"
				if object.new_record? 
					result += @template.link_to("<i class=\"icon-plus\"></i>".html_safe + I18n.t("general.action.create"), @template.method(options[:paths][:create]).call, class: "create") if options[:paths] && options[:paths][:create]
				else
					result += @template.link_to("<i class=\"icon-trash\"></i>".html_safe + I18n.t("general.action.destroy"), @template.method(options[:paths][:destroy]).call(object), class: "delete", data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") } ) if options[:paths] && options[:paths][:destroy]
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
			model_class = collection_model_class(objects, options)

			# Normalize columns to Columns object
			columns = Columns.new(columns) if !columns.is_a? Columns
			columns.template = @template

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
							if options[:paths] && options[:paths][:show]
								result += "<td class=\"leaf\" colspan=\"#{ (maximal_level + 1 - level) }\">#{@template.link_to columns.render(column, object), @template.method(options[:paths][:show]).call(object)}</td>"
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
						result += @template.link_to "<i class=\"icon-plus\"></i>".html_safe + I18n.t("general.action.create"), @template.method(options[:paths][:create]).call, method: :post if options[:paths] && options[:paths][:create]
					else
						result += @template.link_to "<i class=\"icon-trash\"></i>".html_safe + I18n.t("general.action.destroy"), @template.method(options[:paths][:destroy]).call(object), method: :delete, data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") } if options[:paths] && options[:paths][:destroy]
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

		def collection_model_class(objects, options)
			
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

	end
end
