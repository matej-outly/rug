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
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def self.row_from_type(object, name, type, options = {})
				
				# Special null cases
				if options[:enable_null] == true
					result = case type.to_sym
						when :boolean then "radios_row(:#{name}, collection: [OpenStruct.new(value: false, label: I18n.t(\"general.attribute.boolean.bool_no\")), OpenStruct.new(value: true, label: I18n.t(\"general.attribute.boolean.bool_yes\"))], value_attr: :value, label_attr: :label, enable_null: true)"
						else nil
					end
				end
				
				# Standard cases
				if result.nil?
					result = case type.to_sym
						when :string then "text_input_row(:#{name}, :text_field, #{options.inspect})"
						when :text then "text_area_row(:#{name}, #{options.inspect})"
						when :integer then "text_input_row(:#{name}, :number_field, #{options.inspect})"
						when :date then "date_picker_row(:#{name}, #{options.inspect})"
						when :time then "time_picker_row(:#{name}, #{options.inspect})"
						when :datetime then "datetime_picker_row(:#{name}, #{options.inspect})"
						when :boolean then "checkbox_row(:#{name}, #{options.inspect})"
						when :file then "dropzone_row(:#{name}, #{options.inspect})"
						when :picture then "dropzone_row(:#{name}, #{options.inspect})" 
						when :enum then "picker_row(:#{name}, #{options.inspect})" 
						when :belongs_to then "picker_row(:#{name}, collection: #{!options[:collection].blank? ? options[:collection] : "nil"}, value_attr: #{!options[:value_attr].blank? ? options[:value_attr] : ":value"}, label_attr: #{!options[:label_attr].blank? ? options[:label_attr] : ":label"})"
						when :has_many then "token_input_row(:#{name}, #{!options[:url].blank? ? '"' + options[:url] + '"' : "nil"}#{!options[:as].blank? ? ", as: " + options[:as] : ""}#{!options[:value_attr].blank? ? ", value_attr: " + options[:value_attr] : ""}#{!options[:label_attr].blank? ? ", label_attr: " + options[:label_attr] : ""})"
						when :address then "address_row(:#{name}, #{options.inspect})"
						when :name then "name_row(:#{name}, #{options.inspect})"
						when :currency then "text_input_row(:#{name}, :number_field, #{options.inspect})"
						when :integer_range then "range_row(:#{name}, #{options.inspect})"
						when :double_range then "range_row(:#{name}, :text_field, #{options.inspect})"
						else "text_input_row(:#{name}, :text_field, #{options.inspect})"
					end
				end
				
				return result
			end

			def generic_row(name, type, options = {})
				p self.class.row_from_type(object, name, type, options)
				return eval("self." + self.class.row_from_type(object, name, type, options))
			end

		end
#	end
end