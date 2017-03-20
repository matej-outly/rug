# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - basic types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# String
		# *********************************************************************

		def self.string(value, options = {})
			
			# No break?
			if options[:no_break] == true
				value = value.to_s.gsub(" ", "&nbsp;").html_safe
			end

			# Truncate?
			if !options[:truncate].nil? && options[:truncate] != false
				truncate_options = options[:truncate].is_a?(Hash) ? options[:truncate] : {}
				value = value.to_s.truncate(truncate_options)
			end

			return value.to_s
		end

		# *********************************************************************
		# Text
		# *********************************************************************

		def self.text(value, options = {})

			# Blank?
			return "" if value.blank?

			# Strip tags?
			if options[:strip_tags] == true
				value = value.to_s.strip_tags
			end

			# Truncate?
			if options[:truncate] != false
				truncate_options = options[:truncate].is_a?(Hash) ? options[:truncate] : {}
				value = value.to_s.truncate(truncate_options)
			end

			return value.html_safe
		end

		# *********************************************************************
		# Integer
		# *********************************************************************

		def self.integer(value, options = {})
			if value.nil?
				return ""
			else
				result = value.to_i.to_s
				result += " " + options[:unit].to_s if options[:unit]
				return result
			end
		end

		# *********************************************************************
		# Float
		# *********************************************************************

		def self.float(value, options = {})
			if value.nil?
				return ""
			else

				# Locale
				if options[:locale]
					locale = options[:locale]
				else
					locale = :cs
				end

				result = @template.number_with_delimiter(value.to_f, locale: locale) 
				result += " " + options[:unit].to_s if options[:unit]
				return result
			end
		end

		# *********************************************************************
		# Double
		# *********************************************************************

		def self.double(value, options = {})
			if value.nil?
				return ""
			else

				# Locale
				if options[:locale]
					locale = options[:locale]
				else
					locale = :cs
				end

				result = @template.number_with_delimiter(value.to_f, locale: locale) 
				result += " " + options[:unit].to_s if options[:unit]
				return result
			end
		end

		# *********************************************************************
		# Currency
		# *********************************************************************

		def self.currency(value, options = {})
			if value.nil?
				return ""
			else

				# Locale
				if options[:locale]
					locale = options[:locale]
				elsif options[:object] && options[:object].respond_to?(:currency_as_locale)
					locale = options[:object].currency_as_locale
				else
					locale = :cs
				end

				return @template.number_to_currency(value, locale: locale).to_s
			end
		end

		# *********************************************************************
		# URL
		# *********************************************************************

		def self.url(value, options = {})
			
			# Label
			if options[:label]
				label = options[:label]
			else
				label = value.to_s
			end
			label = label[7..-1] if label.start_with?("http://")
			label = label[8..-1] if label.start_with?("https://")
			
			# Target
			if options[:target]
				target = options[:target]
			else
				target = "_self"
			end
			
			return @template.link_to(label, value.to_s, target: target).to_s
		end


	end
end