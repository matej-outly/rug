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
					def range_column(new_column, options = {})
					
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
								self.send("#{column.to_s}_min=", nil)
								self.send("#{column.to_s}_max=", nil)
							else
								self.send("#{column.to_s}_min=", value[:min])
								self.send("#{column.to_s}_max=", value[:max])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value_min = self.send("#{column.to_s}_min")
							value_max = self.send("#{column.to_s}_max")
							if value_min.blank? && value_max.blank?
								return nil
							else
								return { min: value_min, max: value_max }
							end
						end

						# Get method
						define_method("#{new_column}_formatted".to_sym) do
							column = new_column
							return RugBuilder::Formatter.range(self.send(column))
						end

					end

					#
					# Add new enum column
					#
					def datetime_range_column(new_column, options = {})
						
						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column

							# Check type
							if !value.nil? && !value.is_a?(Hash)
								raise "Wrong value format, expecting Hash or nil."
							end

							# Filter
							value = value.symbolize_keys.select { |key, value| [:date, :from, :to].include?(key) } if !value.nil?
							
							if value.nil? || value[:date].blank? || value[:from].blank? || value[:to].blank?
								self.send("#{column.to_s}_from=", nil)
								self.send("#{column.to_s}_to=", nil)
							else

								# Parse date
								if value[:date].is_a?(::String)
									date = Date.parse(value[:date])
								else
									date = value[:date]
								end

								# Parse from
								if value[:from].is_a?(::String)
									from = DateTime.parse(value[:from])
								else
									from = value[:from]
								end

								# Parse to
								if value[:to].is_a?(::String)
									to = DateTime.parse(value[:to])
								else
									to = value[:to]
								end

								# Compose
								if !date.nil?
									self.send("#{column.to_s}_from=", DateTime.compose(date, from)) if !from.nil?
									self.send("#{column.to_s}_to=", DateTime.compose(date, to)) if !to.nil?
								else
									self.send("#{column.to_s}_from=", nil)
									self.send("#{column.to_s}_to=", nil)
								end
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value_from = self.send("#{column.to_s}_from")
							value_to = self.send("#{column.to_s}_to")
							if value_from.blank? && value_to.blank?
								return nil
							else
								return { date: value_from.to_date, from: value_from, to: value_to }
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Range)
