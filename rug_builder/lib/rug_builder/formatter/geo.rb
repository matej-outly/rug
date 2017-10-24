# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - geo types TODO bind to maps
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# Geolocation
		# *********************************************************************

		def self.geolocation(value, options = {})
			if value && value[:latitude] && value[:longitude]
				return value[:latitude].to_s.decimal_to_coordinate + "; " + value[:longitude].to_s.decimal_to_coordinate
			else
				return ""
			end
		end

		# *********************************************************************
		# Georectangle
		# *********************************************************************

		def self.georectangle(value, options = {})
			return value.to_s
		end

		# *********************************************************************
		# Geopolygon
		# *********************************************************************

		def self.geopolygon(value, options = {})
			return value.to_s
		end

	end
end