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
		def index(objects, columns, paths)

			result = ""

			# Normalize columns to Columns object
			if !columns.is_a? Columns
				columns = Columns.new(columns)
			end
			columns.template = @template

			# Headers
			columns_headers = columns.headers

			# Table
			result += "<table class=\"index_table striped\">"

			# Table head
			result += "<thead>"
			result += "<tr>"
			columns_headers.each do |column|
				result += "<th>#{objects.human_attribute_name(column.to_s).upcase_first}</th>"
			end
			result += "<th></th>" if paths[:edit]
			result += "<th></th>" if paths[:destroy]	
			result += "</tr>"
			result += "</thead>"

			# Table body
			result += "<tbody>"
			objects.each do |object|
				result += "<tr>"
				columns_headers.each_with_index do |column, idx|
					if idx == 0 && paths[:show]
						result += "<td>#{@template.link_to columns.render(column, object), @template.method(paths[:show]).call(object)}</td>"
					else
						result += "<td>#{columns.render(column, object)}</td>"
					end
				end
				result += "<td>#{@template.link_to "<i class=\"icon-pencil\"></i>".html_safe + I18n.t("general.action.edit"), @template.method(paths[:edit]).call(object)}</td>" if paths[:edit]
				result += "<td>#{@template.link_to "<i class=\"icon-trash\"></i>".html_safe + I18n.t("general.action.destroy"), @template.method(paths[:destroy]).call(object), method: :delete, data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") }}</td>" if paths[:destroy]
				result += "</tr>"
			end
			result += "</tbody>"

			# Table
			result += "</table>"

			# Model class
			model_class = objects.class.to_s.deconstantize
			if !model_class.blank?
				model_class = model_class.constantize
			else
				model_class = nil
			end

			# Shown items
			result += "<div class=\"shown_items\">#{I18n.t("general.shown").upcase_first}: #{objects.length}#{((model_class && model_class.respond_to?(:count)) ? ("/" + model_class.count.to_s) : "")}</div>"

			return result.html_safe
		end

		#
		# Render show table
		#
		def show(object, columns)

			result = ""

			# Normalize columns to Columns object
			if !columns.is_a? Columns
				columns = Columns.new(columns)
			end
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

	end
end
