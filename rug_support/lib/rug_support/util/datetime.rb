# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * DateTime utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 5. 4. 2015
# *
# *****************************************************************************

class DateTime

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

	#
	# Compose date and time into one datetime
	#
	def self.compose(date, time)
		if time.is_a?(String) 
			time = DateTime.parse(time)
		end
		time_utc = time.utc
		result = DateTime.new(
			date.year, 
			date.month, 
			date.mday, 
			time_utc.strftime("%k").to_i, # hour
			time_utc.strftime("%M").to_i, # minute
			time_utc.strftime("%S").to_i # second
		).in_time_zone(Time.zone)
		result += (time.strftime("%:z").to_i - result.strftime("%:z").to_i).hours
		return result
	end

end