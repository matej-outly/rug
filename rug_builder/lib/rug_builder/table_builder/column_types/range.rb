# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - range type
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
			# Enum
			# *********************************************************************

			def validate_range_options(column_spec)
				return true
			end
			
			def render_range(column, object)
				value = object.send(column.to_s)
				return value[:formatted]
			end

		end
	end
end