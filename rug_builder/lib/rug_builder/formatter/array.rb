# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - array type
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# String array
		# *********************************************************************

		def self.string_array(value, options = {})
			
			# Check format
			if options[:format]
				format = options[:format]
			else
				format = :comma
			end
			if ![:comma, :br].include?(format)
				raise "Unknown format #{format}."
			end

			# Get join string according to format
			join_string = case format
				when :comma then ", "
				when :br then "<br/>"
			end

			if !value.blank?
				return value.map { |value_part| self.string(value_part, options) }.join(join_string)
			else
				return ""
			end
		end

		# *********************************************************************
		# Integer array
		# *********************************************************************

		def self.integer_array(value, options = {})
			
			# Check format
			if options[:format]
				format = options[:format]
			else
				format = :comma
			end
			if ![:comma, :br].include?(format)
				raise "Unknown format #{format}."
			end

			# Get join string according to format
			join_string = case format
				when :comma then ", "
				when :br then "<br/>"
			end

			if !value.blank?
				return value.map { |value_part| self.integer(value_part, options) }.join(join_string)
			else
				return ""
			end
		end

		# *********************************************************************
		# Enum array
		# *********************************************************************

		def self.enum_array(value, options = {})
			
			# Check format
			if options[:format]
				format = options[:format]
			else
				format = :comma
			end
			if ![:comma, :br].include?(format)
				raise "Unknown format #{format}."
			end

			# Get join string according to format
			join_string = case format
				when :comma then ", "
				when :br then "<br/>"
			end

			if !value.blank?
				return value.map { |value_part| self.enum(value_part, options) }.join(join_string)
			else
				return ""
			end
		end

	end
end