# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - address type
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
			# Address
			# *********************************************************************

			def validate_address_options(column_spec)
				return true
			end

			def render_address(column, object)
				value = object.send("#{column.to_s}_formated".to_sym)
				return value
			end

		end
	end
end