# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - name type
# *
# * Author: Matěj Outlý
# * Date  : 30. 11. 2015
# *
# *****************************************************************************

module RugBuilder
	class TableBuilder
		class Columns

		protected

			# *********************************************************************
			# Name
			# *********************************************************************

			def validate_name_options(column_spec)
				return true
			end

			def render_name(column, object)
				value = object.send(column)
				return value[:formatted]
			end

		end
	end
end