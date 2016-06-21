# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - datetime types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

require "truncate_html"

module RugBuilder
	class Formatter

		# *********************************************************************
		# Date
		# *********************************************************************

		def self.date(value, options = {})
			
			# Blank?
			return "" if value.blank?
			
			return I18n.l(value)
		end

		# *********************************************************************
		# Time
		# *********************************************************************

		def self.time(value, options = {})

			# Blank?
			return "" if value.blank?
			
			# Check format
			if options[:format]
				format = options[:format]
			else
				format = :hour_min
			end
			if ![:hour_min, :min_sec, :hour_min_sec].include?(format)
				raise "Unknown format #{format}."
			end

			return value.strftime(I18n.t("time.formats.#{format.to_s}"))
		end

		# *********************************************************************
		# Datetime
		# *********************************************************************

		def self.datetime(value, options = {})
			
			# Blank?
			return "" if value.blank?
			
			return I18n.l(value)
		end

		# *********************************************************************
		# Duration
		# *********************************************************************

		def self.duration(value, options = {})
			
			# Blank?
			return "" if value.blank?

			# Parts
			days = value.days_since_new_year
			hours = value.hour
			minutes = value.min
			seconds = value.sec

			result = []
			result << days.to_s + " " + I18n.t("general.attribute.duration.days").downcase_first if days > 0
			result << hours.to_s + " " + I18n.t("general.attribute.duration.hours").downcase_first if hours > 0
			result << minutes.to_s + " " + I18n.t("general.attribute.duration.minutes").downcase_first if minutes > 0
			result << seconds.to_s + " " + I18n.t("general.attribute.duration.seconds").downcase_first if seconds > 0
			return result.join(", ")
		end

	end
end