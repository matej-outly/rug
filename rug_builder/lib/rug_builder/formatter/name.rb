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

					# Title
					if !value_title.blank?
						if options[:strong_title] == true
							result += "<strong>#{value_title}</strong> "
						else
							result += "#{value_title} "
						end
					end
					
					# Firstname
					if !value_firstname.blank?
						if options[:strong_firstname] == true
							result += "<strong>#{value_firstname}</strong> "
						else
							result += "#{value_firstname} "
						end
					end
					
					# Lastname
					if options[:strong_lastname] == true
						result += "<strong>#{value_lastname}</strong>"
					else
						result += "#{value_lastname}"
					end
					
					return result
				end
			else
				return ""
			end
		end

	end
end