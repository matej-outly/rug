# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Date utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 5. 4. 2015
# *
# *****************************************************************************

class Date

	#
	# Get number of days since New Year
	#
	def days_since_new_year
		return (self.to_date - Date.new(self.year, 1, 1)).to_i
	end

	#
	# Get first bussiness day after this date
	#
	def first_business_day_after
		date = self.dup
		while !date.workday? && Holidays.on(date, :cz).empty? # Is workday and not holiday
			date = date + 1.day	
		end
		return date
	end

end
