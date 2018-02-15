# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - address type
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# Address
		# *********************************************************************

		def self.address(value, options = {})
			if !value.nil?
				value_street = value[:street]
				value_number = value[:number]
				value_zipcode = value[:zipcode]
				value_city = value[:city]
				if value_street.blank? && value_number.blank? && value_zipcode.blank? && value_city.blank?
					return ""
				else
					result = ""

					# Street
					if !value_street.blank?
						result += value_street
					end
					
					# Number
					if !value_number.blank? && !result.blank?
						result += " "
						result += value_number
					end

					# City and zipcode
					if !value_city.blank? || !value_zipcode.blank?
						result += ", " if !result.blank?

						if !value_zipcode.blank?
							result += value_zipcode
							result += " "
						end

						if !value_city.blank?
							result += value_city
						end
					end
					return result
				end
			else
				return ""
			end
		end

	end
end