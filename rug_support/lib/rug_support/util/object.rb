# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Object utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 6. 6. 2014
# *
# *****************************************************************************

class Object

	#
	# Is scalar type?
	#
	def rug_is_a_scalar?
		return (self.is_a? String) || (self.is_a? Symbol) || (self.is_a? Numeric) || (self.rug_is_a_boolean?)
	end

	#
	# Is boolean type?
	#
	def rug_is_a_boolean?
		return (self.is_a? TrueClass) || (self.is_a? FalseClass) 
	end

end