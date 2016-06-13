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
		# Enum
		# *********************************************************************
		
		def self.enum(value, options = {})
			
			# Blank?
			return "" if value.blank?
			
			return value.label
		end

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
		# State
		# *********************************************************************
		
		def self.state(value = nil, options = {})
			
			# Check format
			if options[:format]
				format = options[:format]
			else
				format = :color
			end
			if ![:color, :icon, :color_icon].include?(format)
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

			# Get value
			if object.class.has_enum?(column)
				value_obj = object.send("#{column.to_s}_obj".to_sym)
				value = value_obj.value
				label = value_obj.label
				color = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_colors.#{value}")
				icon = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_icons.#{value}")
				return "" if value.blank?
			else # Bool
				value = object.send(column.to_sym)
				if value == true # Special value TRUE
					value = "yes"
				elsif value == false # Special value FALSE
					value = "no"
				else
					return ""
				end
				if options[:bool_as_enum] == true
					label = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_values.bool_#{value}")
					color = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_colors.bool_#{value}")
					icon = I18n.t("activerecord.attributes.#{object.class.model_name.i18n_key}.#{column.to_s}_icons.bool_#{value}")
				else
					label = I18n.t("general.attribute.boolean.bool_#{value}")
					color = I18n.t("general.attribute.boolean_colors.bool_#{value}")
					icon = I18n.t("general.attribute.boolean_icons.bool_#{value}")
				end
			end

			# CSS classes
			klass = []
			klass << "default label"
			klass << "state-#{value}"
			klass << "color-#{color}" if format == :color || format == :color_icon
			klass << "ttip" if options[:tooltip] == true

			# Render
			result = "<div class=\"#{klass.join(" ")}\" #{@columns[column][:tooltip] == true ? "data-tooltip=\"" + label + "\"" : ""}>"
			result += "<i class=\"icon-#{icon}\"></i>"  if format == :icon || format == :color_icon
			result += label if options[:tooltip] != true
			result += "</div>"
			return result
		end

	end
end
