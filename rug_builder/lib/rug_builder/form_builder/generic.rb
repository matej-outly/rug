# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - generic
# *
# * Author: Matěj Outlý
# * Date  : 23. 11. 2015
# *
# *****************************************************************************

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder

		def self.row_from_type(object, name, type)
			return case type.to_sym
				when :string then "text_input_row(:#{name})"
				when :text then "text_area_row(:#{name})"
				when :integer then "text_input_row(:#{name}, :number_field)"
				when :date then "datepicker_row(:#{name})"
				when :time then "text_input_row(:#{name}, :time_field)"
				when :datetime then "text_input_row(:#{name}, :datetime_local_field)"
				when :boolean then "checkbox_row(:#{name})"
				when :file then "dropzone_row(:#{name})"
				when :picture then "dropzone_row(:#{name})" 
				when :enum then "picker_row(:#{name})" 
				when :belongs_to then "picker_row(:#{name})"
				when :address then "address_row(:#{name})"
				when :currency then "text_input_row(:#{name}, :number_field)"
				when :range then "range_row(:#{name})"
				else "text_input_row(:#{name})"
			end
		end

		def generic_row(name, type)
			return eval("self." + self.class.row_from_type(object, name, type))
		end

	end
end