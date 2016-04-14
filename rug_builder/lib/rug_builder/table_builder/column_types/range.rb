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
			# Generic range
			# *********************************************************************

			def validate_range_options(column_spec)
				return true
			end
			
			def render_range(column, object)
				value = object.send(column.to_s)
				if !value.nil?
					return value[:formatted]
				else
					return ""
				end
			end

			# *********************************************************************
			# Integer range
			# *********************************************************************

			def validate_integer_range_options(column_spec)
				return true
			end
			
			def render_integer_range(column, object)
				value = object.send(column.to_s)
				if !value.nil?
					return value[:formatted]
				else
					return ""
				end
			end

			# *********************************************************************
			# Double range
			# *********************************************************************

			def validate_double_range_options(column_spec)
				return true
			end
			
			def render_double_range(column, object)
				value = object.send(column.to_s)
				if !value.nil?
					return value[:formatted]
				else
					return ""
				end
			end

		end
	end
end