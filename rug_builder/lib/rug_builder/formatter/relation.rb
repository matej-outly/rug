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
			if options[:label_attr].nil?
				raise "Please, supply a label attr column."
			end

			# Get label
			label = value.send(options[:label_attr])

			# Truncate?
			if !options[:truncate].nil? && options[:truncate] != false
				truncate_options = options[:truncate].is_a?(Hash) ? options[:truncate] : {}
				label = label.to_s.truncate(truncate_options)
			end

			if options[:path]
				return "<a href=\"#{RugSupport::PathResolver.new(@template).resolve(options[:path], value)}\">#{label}</a>"
			else
				return label
			end
		end

		# *********************************************************************
		# Has many
		# *********************************************************************

		def self.has_many(collection, options = {})
			
			# Check label
			if options[:label_attr].nil?
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
				
				# Order
				if options[:order]
					collection = collection.order(options[:order])
				end

				# Limit
				if options[:limit]
					collection = collection.limit(options[:limit])
				end

				arr = []
				collection.each do |item|

					# Get label
					label = item.send(options[:label_attr])

					# Truncate?
					if !options[:truncate].nil? && options[:truncate] != false
						truncate_options = options[:truncate].is_a?(Hash) ? options[:truncate] : {}
						label = label.to_s.truncate(truncate_options)
					end

					if options[:path]
						arr << "<a href=\"#{RugSupport::PathResolver.new(@template).resolve(options[:path], item)}\">#{label}</a>"
					else
						arr << label
					end
				end
				return arr.join(join_string)
			else
				return ""
			end
		end

	end
end