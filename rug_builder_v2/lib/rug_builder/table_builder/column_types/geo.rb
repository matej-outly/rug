# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - geo types TODO bind to maps
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
			# Geolocation
			# *********************************************************************

			def validate_geolocation_options(column_spec)
				return true
			end

			def render_geolocation(column, object)
				value = object.send("#{column.to_s}".to_sym)
				return value
			end

			# *********************************************************************
			# Georectangle
			# *********************************************************************

			def validate_georectangle_options(column_spec)
				return true
			end

			def render_georectangle(column, object)
				value = object.send("#{column.to_s}".to_sym)
				return value
			end

			# *********************************************************************
			# Geopolygon
			# *********************************************************************

			def validate_geopolygon_options(column_spec)
				return true
			end

			def render_geopolygon(column, object)
				value = object.send("#{column.to_s}".to_sym)
				return value
			end

		end
	end
end