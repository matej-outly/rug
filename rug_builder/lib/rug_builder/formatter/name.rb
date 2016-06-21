# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - name type
# *
# * Author: Matěj Outlý
# * Date  : 30. 11. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# Name
		# *********************************************************************

		def self.name(value, options = {})
			if !value.nil?
				value_title = value[:title]
				value_firstname = value[:firstname]
				value_lastname = value[:lastname]
				if value_firstname.blank? && value_lastname.blank?
					return ""
				else
					result = ""
					result += "#{value_title.to_s} " if !value_title.blank?
					result += "#{value_firstname.to_s} " if !value_firstname.blank?
					result += value_lastname.to_s
					return result
				end
			else
				return ""
			end
		end

	end
end