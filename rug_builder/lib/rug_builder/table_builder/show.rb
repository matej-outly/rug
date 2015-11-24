# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - show
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class TableBuilder

		#
		# Render show table
		#
		def show(object, columns, options = {})

			# Check
			if object.nil?
				raise "Given object is nil."
			end

			# Normalize columns to Columns object
			columns = normalize_columns(columns)

			# Table
			result = ""
			result += "<table class=\"show_table #{options[:class].to_s}\">"

			# Table body
			result += "<tbody>"
			columns.headers.each do |column|
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