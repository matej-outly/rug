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
	# Convert string to URL suitable format (= url-suitable-format)
	#
	def to_url
		return I18n.transliterate(self).
			downcase.
			gsub(/[^a-z0-9\s,\-_]/, "").
			gsub(/[\s,\-_]+/, "-")
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