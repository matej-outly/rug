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
					def geolocation_column(new_column)
					
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
							value = value.symbolize_keys.select { |key, value| [:longitude, :latitude].include?(key) } 
							
							# Store
							if value.blank? || value[:latitude].blank? || value[:longitude].blank?
								write_attribute("#{column.to_s}_latitude", nil)
								write_attribute("#{column.to_s}_longitude", nil)
							else
								write_attribute("#{column.to_s}_latitude", value[:latitude])
								write_attribute("#{column.to_s}_longitude", value[:longitude])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value_latitude = read_attribute("#{column.to_s}_latitude")
							value_longitude = read_attribute("#{column.to_s}_longitude")
							if value_latitude.blank? || value_longitude.blank?
								return nil
							else
								return { latitude: value_latitude, longitude: value_longitude }
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Geolocation)
