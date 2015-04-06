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
	# Get monday of current week
	#
	def week_monday
		return self - (self.cwday - 1).days
	end

end
