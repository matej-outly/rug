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

	def diff(array_2, options = {}, &block)
		Array.diff(self, array_2, options, &block)
		return self
	end

	#
	# Find differencied between array 1 and array 2
	#
	def self.diff(array_1, array_2, options = {}, &block)

		# Arrays for compare
		compare_array_1 = array_1
		compare_array_1 = array_1.map { |item| item.send(options[:compare_attr_1]) } if options[:compare_attr_1]
		compare_array_2 = array_2
		compare_array_2 = array_2.map { |item| item.send(options[:compare_attr_2]) } if options[:compare_attr_2]

		# Items to remove
		items_to_remove = []
		same_items = []
		array_1.each do |item|
			compare_item = item
			compare_item = item.send(options[:compare_attr_1]) if options[:compare_attr_1]
			if !compare_array_2.include?(compare_item)
				items_to_remove << item
			else
				same_items << item
			end
		end

		# Items to add
		items_to_add = []
		array_2.each do |item|
			compare_item = item
			compare_item = item.send(options[:compare_attr_2]) if options[:compare_attr_2]
			items_to_add << item if !compare_array_1.include?(compare_item)
		end

		# Perform actions
		items_to_remove.each do |item|
			block.call(:remove, item)
		end
		items_to_add.each do |item|
			block.call(:add, item)
		end
		same_items.each do |item|
			block.call(:equal, item)
		end

		return array_1
	end

	#
	# Convert all values in array into integer
	#
	def integerize
		return self.map{ |v| v.to_i } 
	end

end