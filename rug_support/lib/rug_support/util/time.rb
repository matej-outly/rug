# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Time utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 5. 4. 2015
# *
# *****************************************************************************

class Time

	#
	# Get number of days since New Year
	#
	def days_since_new_year
		return (self.to_date - Date.new(self.year, 1, 1)).to_i
	end

	#
	# Get number of minutes since midnight
	#
	def minutes_since_midnight
		return (self.seconds_since_midnight.to_i / 60).floor
	end

end