# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Array utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 15. 2. 2016
# *
# *****************************************************************************

class Array

	#
	# Iterate through array in reverse order with index
	#
	def reverse_each_with_index(&block)
		(0...length).reverse_each do |i|
			block.call(self[i], i)
		end
	end

end