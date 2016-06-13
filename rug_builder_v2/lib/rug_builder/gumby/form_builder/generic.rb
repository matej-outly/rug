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
#	module Gumby
		class FormBuilder < ActionView::Helpers::FormBuilder

			def self.row_from_type(object, name, type, options = {})
				
				# Special null cases
				if options[:enable_null] == true
					result = case type.to_sym
						when :boolean then "radios_row(:#{name}, [OpenStruct.new(value: false, label: I18n.t(\"general.attribute.boolean.bool_no\")), OpenStruct.new(value: true, label: I18n.t(\"general.attribute.boolean.bool_yes\"))], :value, :label, enable_null: true)"
						else nil
					end
				end
				
				# Standard cases
				if result.nil?
					result = case type.to_sym
						when :string then "text_input_row(:#{name})"
						when :text then "text_area_row(:#{name})"
						when :integer then "text_input_row(:#{name}, :number_field)"
						when :date then "date_picker_row(:#{name})"
						when :time then "time_picker_row(:#{name})"
						when :datetime then "datetime_picker_row(:#{name})"
						when :boolean then "checkbox_row(:#{name})"
						when :file then "dropzone_row(:#{name})"
						when :picture then "dropzone_row(:#{name})" 
						when :enum then "picker_row(:#{name})" 
						when :belongs_to then "picker_row(:#{name}, #{!options[:collection].blank? ? options[:collection] : "nil"}, #{!options[:value_attr].blank? ? options[:value_attr] : ":value"}, #{!options[:label_attr].blank? ? options[:label_attr] : ":label"})"
						when :has_many then "token_input_row(:#{name}, #{!options[:url].blank? ? '"' + options[:url] + '"' : "nil"}#{!options[:as].blank? ? ", as: " + options[:as] : ""}#{!options[:value_attr].blank? ? ", value_attr: " + options[:value_attr] : ""}#{!options[:label_attr].blank? ? ", label_attr: " + options[:label_attr] : ""})"
						when :address then "address_row(:#{name})"
						when :name then "name_row(:#{name})"
						when :currency then "text_input_row(:#{name}, :number_field)"
						when :integer_range then "range_row(:#{name})"
						when :double_range then "range_row(:#{name}, :text_field)"
						when :string_array then "checkboxes_row(:#{name})"
						else "text_input_row(:#{name})"
					end
				end
				
				return result
			end

			def generic_row(name, type, options = {})
				return eval("self." + self.class.row_from_type(object, name, type, options))
			end

		end
#	end
end