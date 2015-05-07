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
	# Remove characters from string on the left and right side
	#
	def trim(chars)
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

end