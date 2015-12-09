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
			# Array
			# *********************************************************************

			def validate_array_options(column_spec)
				return true
			end

			def render_array(column, object)
				if @columns[column][:format]
					format = @columns[column][:format]
				else
					format = :comma
				end
				if format == :comma
					value = object.send(column)
					value = object.send(column).join(", ") if !value.blank?
				else
					raise "Unknown format #{format}."
				end
				return value
			end

		end
	end
end