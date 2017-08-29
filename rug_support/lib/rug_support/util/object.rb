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
	def is_scalar?
		return (self.is_a? String) || (self.is_a? Symbol) || (self.is_a? Numeric) || (self.is_boolean?)
	end

	#
	# Is boolean type?
	#
	def is_boolean?
		return (self.is_a? TrueClass) || (self.is_a? FalseClass) 
	end

	#
	# Is a valid number or string representing number?
	#
	def is_numeric?
		return (self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s)
	end

end