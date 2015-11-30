# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - basic types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

require "truncate_html"

module RugBuilder
	class TableBuilder
		class Columns

		protected

			# *********************************************************************
			# String
			# *********************************************************************

			def validate_string_options(column_spec)
				return true
			end

			def render_string(column, object)
				value = object.send(column).to_s
				if @columns[column][:no_break] == true
					value = value.gsub(" ", "&nbsp;").html_safe
				end
				return value
			end

			# *********************************************************************
			# Text
			# *********************************************************************

			def validate_text_options(column_spec)
				return true
			end

			def render_text(column, object)
				value = object.send(column)
				return "" if value.blank?
				if @columns[column][:truncate] == false
					return value.html_safe
				else
					html_string = TruncateHtml::HtmlString.new(value)
					return TruncateHtml::HtmlTruncator.new(html_string, {}).truncate.html_safe
				end
			end

			# *********************************************************************
			# Integer
			# *********************************************************************

			def validate_integer_options(column_spec)
				return true
			end

			def render_integer(column, object)
				value = object.send(column)
				return value.to_i.to_s
			end

			# *********************************************************************
			# Currency
			# *********************************************************************

			def validate_currency_options(column_spec)
				return true
			end

			def render_currency(column, object)
				if @columns[column][:locale]
					locale = @columns[column][:locale]
				else
					locale = :cs
				end
				value = object.send(column)
				return @template.number_to_currency(value, locale: locale)
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
					return I18n.t("general.bool_yes")
				else
					return I18n.t("general.bool_no")
				end
			end

		end
	end
end