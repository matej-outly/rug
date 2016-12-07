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

	#
	# Slice array by first letter of title (defined by title_block parameter) 
	#
	def slice_by_alphabet(&title_block)
		result = []
		current_letter = nil
		self.each do |item| 
			if !item.name.blank?
				item_title = title_block.call(item)
				item_first_letter = item_title.first.downcase
				if item_first_letter != current_letter
					result << {
						first_letter: item_first_letter,
						content: []
					}
					current_letter = item_first_letter
				end
				result.last[:content] << item
			end
		end
		return result
	end

	#
	# Join array using extra last join string
	# 
	def join_with_extra_last(join_string_common, join_string_last)
		result = ""
		self.each_with_index do |item, index|
			result += join_string_common.to_s if index != 0 && index < self.length-1
			result += join_string_last.to_s if index != 0 && index >= self.length-1
			result += item.to_s
		end
		return result
	end

end