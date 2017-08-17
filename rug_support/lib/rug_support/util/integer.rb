# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integer utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 17. 8. 2017
# *
# *****************************************************************************

class Integer
	
	#
	# Compute percantage based on two float values
	#
	def self.percentage(value_1, value_2)
		if value_2
			if value_1.to_f >= value_2.to_f
				return 100
			else
				return ((value_1.to_f * 100.0) / value_2.to_f).to_i
			end
		else
			return 100
		end
	end

end