# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * String utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 6. 5. 2014
# *
# *****************************************************************************

require "i18n"
require "truncate_html"

class String

	#
	# Convert CamelCase string to snake_case
	#
	def to_snake
		return self.
			gsub(/::/, '/').
			gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
			gsub(/([a-z\d])([A-Z])/,'\1_\2').
			tr("-", "_").
			downcase
	end

	#
	# Convert snake_case string to CamelCase
	#
	def to_camel
		return self.
			trim("/").
			split("/").
			map { |item| item.camelize }.
			join("::")
	end

	#
	# Upper-case with multibyte support
	#
	def mb_upcase
		return self.mb_chars.upcase.to_s
	end

	#
	# Lower-case with multibyte support
	#
	def mb_downcase
		return self.mb_chars.downcase.to_s
	end

	#
	# Upper-case only first letter, rest of the string is kept
	#
	def upcase_first
		return self[0].upcase + self[1..-1]
	end

	#
	# Lower-case only first letter, rest of the string is kept
	#
	def downcase_first
		return self[0].downcase + self[1..-1]
	end

	#
	# Upper-case only first letter, rest of the string is kept, multibyte support
	#
	def mb_upcase_first
		return self[0].mb_upcase + self[1..-1]
	end

	#
	# Lower-case only first letter, rest of the string is kept, multibyte support
	#
	def mb_downcase_first
		return self[0].mb_downcase + self[1..-1]
	end

	#
	# Remove characters from string on the left and right side
	#
	def trim(chars = "\s")
		return self.
			sub(/^[#{Regexp.escape(chars)}]*/, "").
			sub(/[#{Regexp.escape(chars)}]*$/, "")
	end

	#
	# Remove characters from string on the left side
	#
	def ltrim(chars = "\s")
		return self.
			sub(/^[#{Regexp.escape(chars)}]*/, "")
	end

	#
	# Remove characters from string on the right side
	#
	def rtrim(chars = "\s")
		return self.
			sub(/[#{Regexp.escape(chars)}]*$/, "")
	end

	#
	# Convert string to URL suitable format (= url-suitable-format)
	#
	def to_url
		return I18n.transliterate(self).
			strip_tags.
			gsub("&nbsp;", " ").
			gsub("&amp;", " ").
			downcase.
			gsub(/[^a-z0-9\.\s,\-_]/, "").
			gsub(/[\.\s,\-_]+/, "-").
			trim("-")
	end

	#
	# Truncate
	#
	def truncate(options = {})
		return TruncateHtml::HtmlTruncator.new(TruncateHtml::HtmlString.new(self), options).truncate
	end

	#
	# Strip tags
	#
	def strip_tags
		return ActionController::Base.helpers.strip_tags(self)
	end

	#
	# Sanitize tags
	#
	def sanitize(options = {})
		return ActionController::Base.helpers.sanitize(self, options)
	end

	# 
	# Convert coordinate in degree format to decimal format
	#
	def coordinate_to_decimal
		return nil if self.blank?
		result = 0.0
		minus = false
		
		# Degrees
		splitted_1 = self.split("°")
		return nil if splitted_1.length != 2
		result += splitted_1[0].to_i.to_f

		# Minus correction
		if result < 0.0
			minus = true
			result = -result
		end

		# Minutes
		splitted_2 = splitted_1[1].split("'")
		return nil if splitted_2.length != 2
		result += (splitted_2[0].to_i.to_f / 60.to_f).to_f

		# Seconds
		result += (splitted_2[1].to_f / 3600.to_f).to_f

		# Minus correction
		if minus
			result = -result
		end

		return result
	end

end

module RugSupport
	module Util
		class String

			#
			# Generate random string
			#
			def self.random(length = nil)
				length = 128 if length.nil?
				#return SecureRandom.random_number(36**length).to_s(36).rjust(length, "0")
				#return SecureRandom.base64(length)[0..(length-1)]
				return SecureRandom.hex(length/2 + 1)[0..(length-1)]
			end

		end
	end
end