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
				value_postcode = value[:postcode]
				value_city = value[:city]
				if value_street.blank? && value_number.blank? && value_postcode.blank? && value_city.blank?
					return ""
				else
					return "#{value_street} #{value_number}, #{value_postcode} #{value_city}"
				end
			else
				return ""
			end
		end

	end
end