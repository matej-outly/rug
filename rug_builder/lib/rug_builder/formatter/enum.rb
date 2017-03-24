# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - enum type
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# Boolean
		# *********************************************************************

		def self.boolean(value, options = {})
			if value == true
				return I18n.t("general.attribute.boolean.bool_yes")
			else
				return I18n.t("general.attribute.boolean.bool_no")
			end
		end

		# *********************************************************************
		# Enum
		# *********************************************************************
		
		def self.enum(value, options = {})
			
			# Blank?
			return "" if value.blank?
			
			# Object
			if options[:object].nil?
				raise "Please, supply object in options."
			end
			object = options[:object]

			# Column
			if options[:column].nil?
				raise "Please, supply column in options."
			end
			column = options[:column]

			# Get value
			value_obj = object.class.send("available_#{column.to_s.pluralize}".to_sym).select { |obj| obj.value == value }.first

			if value_obj
				return value_obj.label
			else
				return ""
			end
		end

		# *********************************************************************
		# State
		# *********************************************************************
		
		def self.state(value = nil, options = {})
			
			# Check format
			if options[:format]
				format = options[:format]
			else
				format = :label
			end
			if ![:label, :button].include?(format)
				raise "Unknown format #{format}."
			end

			# Object
			if options[:object].nil?
				raise "Please, supply object in options."
			end
			object = options[:object]

			# Column
			if options[:column].nil?
				raise "Please, supply column in options."
			end
			column = options[:column]

			# Normalize value
			value = value.to_s

			# Get value, color and icon
			if object.class.respond_to?("available_#{column.to_s.pluralize}".to_sym)	
				value_obj = object.class.send("available_#{column.to_s.pluralize}".to_sym).find { |obj| obj.value == value }
				return "" if value_obj.blank?
				value = value_obj.value
				label = value_obj.label
				color = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_colors.#{value}", default: "")
				icon = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_icons.#{value}", default: "")
			
			else # Bool or different data type => act as bool
				value = object.send(column.to_sym)
				if value == true # Special value TRUE
					value = "yes"
				elsif value == false # Special value FALSE
					value = "no"
				elsif !value.blank? # Not blank value
					value = "yes"
				else
					return ""
				end
				if options[:use_translation] == true
					label = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_values.bool_#{value}", default: "")
					color = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_colors.bool_#{value}", default: "")
					icon = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_icons.bool_#{value}", default: "")
				else
					label = I18n.t("general.attribute.boolean.bool_#{value}", default: "")
					color = I18n.t("general.attribute.boolean_colors.bool_#{value}", default: "")
					icon = I18n.t("general.attribute.boolean_icons.bool_#{value}", default: "")
				end
			end

			if format == :label
				
				el_options = {}
				el_options[:color] = color if !color.blank? && options[:color] != false
				el_options[:tooltip] = label if options[:tooltip] == true
				el_label = ""
				el_label += RugBuilder::IconBuilder.render(icon) if !icon.blank? && options[:icon] != false
				el_label += label if options[:tooltip] != true
				
				return RugBuilder::LabelBuilder.render(el_label, el_options)

			elsif format == :button

				el_options = {}
				el_options[:color] = color if !color.blank? && options[:color] != false
				el_options[:tooltip] = label if options[:tooltip] == true
				el_options[:format] = :button
				el_options[:size] = options[:size] if options[:size]
				el_label = ""
				el_label += RugBuilder::IconBuilder.render(icon) if !icon.blank? && options[:icon] != false
				el_label += label if options[:tooltip] != true
				
				builder = RugBuilder::ButtonBuilder.new(@template)
				return builder.button_group do |b|
					result_1 = ""
					result_1 += b.button(el_label, nil, el_options)
					if options[:path]
						result_1 += b.dropdown_button(nil, el_options) do |m| 
							result_2 = ""
							object.class.send("available_#{column.to_s.pluralize}".to_sym).each do |available_state|
								result_2 += m.item(available_state.label, RugSupport::PathResolver.new(@template).resolve(options[:path], object, available_state.value), method: "put")
							end
							result_2.html_safe
						end
					end
					result_1.html_safe
				end

			end

		end

	end
end
