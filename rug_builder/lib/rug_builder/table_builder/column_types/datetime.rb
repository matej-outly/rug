# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - datetime types
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
			# Date
			# *********************************************************************

			def validate_date_options(column_spec)
				return true
			end

			def render_date(column, object)
				value = object.send(column)
				return "" if value.blank?
				return I18n.l(value)
			end

			# *********************************************************************
			# Time
			# *********************************************************************

			def validate_time_options(column_spec)
				return true
			end

			def render_time(column, object)
				value = object.send(column)
				return "" if value.blank?
				return value.strftime(I18n.t("time.formats.raw"))
			end

			# *********************************************************************
			# Datetime
			# *********************************************************************

			def validate_datetime_options(column_spec)
				return true
			end

			def render_datetime(column, object)
				value = object.send(column)
				return "" if value.blank?
				return I18n.l(value)
			end

			# *********************************************************************
			# Duration
			# *********************************************************************

			def validate_duration_options(column_spec)
				return true
			end

			def render_duration(column, object)
				value = object.send(column)
				return "" if value.blank?
				return value.days_since_new_year.to_s + " " + I18n.t("general.attribute.duration.days").downcase_first + ", " + value.hour.to_s + " " + I18n.t("general.attribute.duration.hours").downcase_first + ", " + value.min.to_s + " " + I18n.t("general.attribute.duration.minutes").downcase_first
			end

		end
	end
end