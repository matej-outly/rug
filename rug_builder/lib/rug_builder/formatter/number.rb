# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - number types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# Integer
		# *********************************************************************

		def self.integer(value, options = {})
			return "" if value.blank?

			# Format
			result = value.to_i.to_s
			result += ("&nbsp;" + options[:unit].to_s).html_safe if options[:unit]
			return result.html_safe
		end

		# *********************************************************************
		# Float
		# *********************************************************************

		def self.float(value, options = {})
			return "" if value.blank?

			# Locale
			if options[:locale]
				locale = options[:locale]
			else
				locale = :cs
			end

			# Precision
			if options[:precision]
				precision = options[:precision].to_i
			else
				precision = 1
			end

			# Format
			result = @template.number_with_precision(value.to_f, locale: locale, precision: precision) 
			result += ("&nbsp;" + options[:unit].to_s).html_safe if options[:unit]
			return result.html_safe
		end

		# *********************************************************************
		# Double
		# *********************************************************************

		def self.double(value, options = {})
			return "" if value.blank?

			# Locale
			if options[:locale]
				locale = options[:locale]
			else
				locale = :cs
			end

			# Precision
			if options[:precision]
				precision = options[:precision].to_i
			else
				precision = 1
			end

			# Format
			result = @template.number_with_precision(value.to_f, locale: locale, precision: precision)
			result += ("&nbsp;" + options[:unit].to_s).html_safe if options[:unit]
			return result.html_safe
		end

		# *********************************************************************
		# Currency
		# *********************************************************************

		def self.currency(value, options = {})
			return "" if value.blank?

			# Locale
			if options[:locale]
				locale = options[:locale]
			elsif options[:object] && options[:object].respond_to?(:currency_as_locale)
				locale = options[:object].currency_as_locale
			else
				locale = :cs
			end

			# Precision
			precision = options[:precision] ? options[:precision] : 2

			return @template.number_to_currency(value, locale: locale, precision: precision).to_s
		end

		# *********************************************************************
		# Rating
		# *********************************************************************

		def self.rating(value, options = {})
			return "" if value.blank?

			# Max
			if options[:max]
				max = options[:max].to_i
				if max <= 0 
					raise "Max value must be above zero."
				end
			else
				max = 5
			end

			# Icons
			symbol_empty = @template.rug_icon((options[:icon_empty] ? options[:icon_empty] : "star-o")).trim
			symbol_half = @template.rug_icon((options[:icon_half] ? options[:icon_half] : "star-half-o")).trim
			symbol_full = @template.rug_icon((options[:icon_full] ? options[:icon_full] : "star")).trim

			# Format
			result = ""
			max.times do |step|
				if value.to_i >= step+1
					result += symbol_full
				elsif value.to_i < step+1
					result += symbol_empty
				end
			end
			return result.html_safe
		end

	end
end