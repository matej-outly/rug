# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Range definition
# *
# * Author: Matěj Outlý
# * Date  : 14. 10. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Range extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new range column
					#
					def range_column(new_column)
					
						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column
							
							# Convert string to Hash 
							if value.is_a? ::String
								if !value.blank?
									value = JSON.parse(value)
								else
									value = nil
								end
							end

							# Check type
							if !value.nil? && !value.is_a?(Hash)
								raise "Wrong value format, expecting Hash or nil."
							end

							# Filter and symbolize keys
							value = value.symbolize_keys.select { |key, value| [:max, :min].include?(key) } 
							
							# Store
							if value.blank?
								write_attribute("#{column.to_s}_min", nil)
								write_attribute("#{column.to_s}_max", nil)
							else
								write_attribute("#{column.to_s}_min", value[:min])
								write_attribute("#{column.to_s}_max", value[:max])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value_min = read_attribute("#{column.to_s}_min")
							value_max = read_attribute("#{column.to_s}_max")
							if value_min.blank? && value_max.blank?
								return nil
							else
								return { min: value_min, max: value_max }
							end
						end

						# Get method
						define_method((new_column.to_s + "_formated").to_sym) do
							column = new_column
							value_min = read_attribute("#{column.to_s}_min")
							value_max = read_attribute("#{column.to_s}_max")
							if value_min.blank? && value_max.blank?
								return nil
							else
								return "#{value_min} - #{value_max}"
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Range)