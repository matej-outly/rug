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

							# Filter
							value = value.select { |key, value| ["longitude", "latitude"].include?(key.to_s) } if !value.nil?
							
							# Store
							if value.blank?
								write_attribute(column.to_sym, nil)
							else
								write_attribute(column.to_sym, value.to_json)
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value = read_attribute(column.to_sym)
							if value.blank?
								return nil
							else
								return JSON.parse(value)
							end
						end

						# Get method
						define_method((new_column.to_s + "_formated").to_sym) do
							column = new_column
							value = send(column.to_sym)
							if value.blank?
								return nil
							else
								return "#{value["longitude"]}, #{value["latitude"]}"
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Geolocation)
