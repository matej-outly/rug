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
#	module Bootstrap
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
				result += "<div class=\"panel panel-default\">"
				result += "<table class=\"table show-table #{options[:class].to_s}\">"

				# Table body
				result += "<tbody>"
				columns.headers.each do |column|
					value = columns.render(column, object)
					if options[:show_blank_rows] == true || !value.blank?
						result += "<tr>"
						result += "<td>#{columns.label(column, object.class)}</td>"
						result += "<td>#{value}</td>"
						result += "</tr>"
					end
				end
				result += "</tbody>"

				# Table
				result += "</table>"
				result += "</div>"

				return result.html_safe
			end
			
		end
#	end
end