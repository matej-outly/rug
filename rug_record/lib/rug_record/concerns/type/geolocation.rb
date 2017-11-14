# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Geolocation definition
# *
# * Author: Matěj Outlý
# * Date  : 13. 10. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Geolocation extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new geolocation column
					#
					def geolocation_column(new_column, options = {})
					
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

							# Check if address and level value part is present
							has_address = self.respond_to?("#{column.to_s}_address")
							has_level = self.respond_to?("#{column.to_s}_level")

							# Filter and symbolize keys
							if !value.blank?
								value = value.symbolize_keys.select { |key, value| [:longitude, :latitude, :address, :level].include?(key) } 
							end

							# Store
							if value.blank? || value[:latitude].blank? || value[:longitude].blank?
								self.send("#{column.to_s}_latitude=", nil)
								self.send("#{column.to_s}_longitude=", nil)
								self.send("#{column.to_s}_address=", nil) if has_address
								self.send("#{column.to_s}_level=", nil) if has_level
							else
								self.send("#{column.to_s}_latitude=", value[:latitude])
								self.send("#{column.to_s}_longitude=", value[:longitude])
								self.send("#{column.to_s}_address=", value[:address]) if has_address
								self.send("#{column.to_s}_level=", value[:level]) if has_level
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column

							# Check if address and level value part is present
							has_address = self.respond_to?("#{column.to_s}_address")
							has_level = self.respond_to?("#{column.to_s}_level")
							
							# Get value parts
							value_latitude = self.send("#{column.to_s}_latitude")
							value_longitude = self.send("#{column.to_s}_longitude")
							value_address = self.send("#{column.to_s}_address") if has_address
							value_level = self.send("#{column.to_s}_level") if has_level
							
							# Form result
							if value_latitude.blank? || value_longitude.blank?
								return nil
							else
								result = { latitude: value_latitude, longitude: value_longitude }
								result[:address] = value_address if has_address
								result[:level] = value_level if has_level
								return result
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Geolocation)
