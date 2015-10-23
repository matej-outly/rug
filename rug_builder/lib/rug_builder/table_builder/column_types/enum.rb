# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - enum type
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

			def validate_enum_options(column_spec)
				return true
			end
			
			def render_enum(column, object)
				value = object.send("#{column.to_s}_obj".to_sym)
				return "" if value.blank?
				return value.label
			end

		end
	end
end