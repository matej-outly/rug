# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - relation types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# Belongs to
		# *********************************************************************

		def self.belongs_to(value, options = {})

			# Blank?
			return "" if value.blank?

			# Check label
			if options[:label].nil?
				raise "Please, supply a label column."
			end

			if options[:path]
				return "<a href=\"#{RugSupport::PathResolver.new(@template).resolve(options[:path], value)}\">#{value.send(options[:label])}</a>"
			else
				return value.send(options[:label])
			end
		end

		# *********************************************************************
		# Has many
		# *********************************************************************

		def self.has_many(collection, options = {})
			
			# Check label
			if options[:label].nil?
				raise "Please, supply a label column."
			end

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

			# Get value and format it
			if !collection.blank?
				if options[:path]
					arr = collection.map { |item| "<a href=\"#{RugSupport::PathResolver.new(@template).resolve(options, item)}\">#{item.send(options[:label])}</a>" }
				else
					arr = collection.map { |item| item.send(options[:label]) }
				end
				return arr.join(join_string)
			else
				return ""
			end
		end

	end
end