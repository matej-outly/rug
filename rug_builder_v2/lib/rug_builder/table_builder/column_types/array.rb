# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - array type
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class TableBuilder
		class Columns

		protected

			# *********************************************************************
			# String array
			# *********************************************************************

			def validate_string_array_options(column_spec)
				return true
			end

			def render_string_array(column, object)
				# Check format
				if @columns[column][:format]
					format = @columns[column][:format]
				else
					format = :comma
				end
				if ![:comma, :br].include?(format)
					raise "Unknown format #{format}."
				end

				# Get join string according to format
				join_string = case format
					when :comma then ", "
					when :br then "<br/>"
				end

				value = object.send(column)
				if !value.blank?
					return value.join(join_string)
				else
					return ""
				end
			end

		end
	end
end