# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - enum type
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class TableBuilder
		class Columns

		protected

			# *********************************************************************
			# Enum
			# *********************************************************************

			def validate_enum_options(column_spec)
				return true
			end
			
			def render_enum(column, object)
				value = object.send("#{column.to_s}_obj".to_sym)
				return "" if value.blank?
				return value.label
			end

			# *********************************************************************
			# Boolean
			# *********************************************************************

			def validate_boolean_options(column_spec)
				return true
			end

			def render_boolean(column, object)
				value = object.send(column)
				if value == true
					return I18n.t("general.attribute.boolean.bool_yes")
				else
					return I18n.t("general.attribute.boolean.bool_no")
				end
			end

			# *********************************************************************
			# State
			# *********************************************************************

			def validate_state_options(column_spec)
				return true
			end
			
			def render_state(column, object)
				
				# Check format
				if @columns[column][:format]
					format = @columns[column][:format]
				else
					format = :color
				end
				if ![:color, :icon, :color_icon].include?(format)
					raise "Unknown format #{format}."
				end

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
					if @columns[column][:bool_as_enum] == true
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
				klass << "ttip" if @columns[column][:tooltip] == true

				# Render
				result = "<div class=\"#{klass.join(" ")}\" #{@columns[column][:tooltip] == true ? "data-tooltip=\"" + label + "\"" : ""}>"
				result += "<i class=\"icon-#{icon}\"></i>"  if format == :icon || format == :color_icon
				result += label if @columns[column][:tooltip] != true
				result += "</div>"
				return result
			end

		end
	end
end