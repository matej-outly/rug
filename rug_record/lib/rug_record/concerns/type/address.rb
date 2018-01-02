# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Address definition
# *
# * Author: Matěj Outlý
# * Date  : 4. 4. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Address extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new address column
					#
					def address_column(new_column, options = {})
					
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
							if !value.blank?
								value = value.symbolize_keys.select { |key, value| [:street, :number, :zipcode, :city].include?(key) } if !value.nil?
							end
							
							# Store
							if value.blank?
								self.send("#{column.to_s}_street=", nil)
								self.send("#{column.to_s}_number=", nil)
								self.send("#{column.to_s}_zipcode=", nil)
								self.send("#{column.to_s}_city=", nil)
							else
								self.send("#{column.to_s}_street=", value[:street])
								self.send("#{column.to_s}_number=", value[:number])
								self.send("#{column.to_s}_zipcode=", value[:zipcode])
								self.send("#{column.to_s}_city=", value[:city])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value_street = self.send("#{column.to_s}_street")
							value_number = self.send("#{column.to_s}_number")
							value_zipcode = self.send("#{column.to_s}_zipcode")
							value_city = self.send("#{column.to_s}_city")
							if value_street.blank? && value_number.blank? && value_zipcode.blank? && value_city.blank?
								return nil
							else
								return { street: value_street, number: value_number, zipcode: value_zipcode, city: value_city }
							end
						end

						# Get method
						define_method("#{new_column}_formatted".to_sym) do
							column = new_column
							return RugBuilder::Formatter.address(self.send(column))
						end

						# Set method
						define_method("#{new_column}_formatted=".to_sym) do |value|
							column = new_column
							parsed_value = self.class.parse_address(value.to_s)
							self.send("#{column}=".to_sym, {
								street: parsed_value[3],
								number: parsed_value[4],
								city: parsed_value[2],
								zipcode: parsed_value[1],
							})
						end

					end

					#
					# Parse address
					#
					def parse_address(address)
						country = nil
						city = nil
						zipcode = nil
						street = nil
						number = nil
						address_parts = address.to_s.split(",").map { |i| i.trim(" ") }
						if address_parts.length >= 1
							country = address_parts.pop
						end
						if address_parts.length >= 1
							city = address_parts.pop
							city_parts = []
							zipcode_parts = []
							zipcode_prefix = true
							city.split(" ").each do |part|
								if zipcode_prefix && /\A\d+\z/.match(part) # Is a positive number
									zipcode_parts << part
								else
									city_parts << part
									zipcode_prefix = false
								end
							end
							city = city_parts.join(" ")
							zipcode = zipcode_parts.join(" ")
						end
						if address_parts.length >= 1
							street = address_parts.join(", ")
							street_parts = street.split(" ")
							street_parts.reverse_each_with_index do |street_part, idx|
								if /\d/.match(street_parts[idx][0])
									number = street_part
									if number[number.length-1] == ","
										if idx > 0
											street_parts[idx-1] += ",";
										end
										number = number.trim(",");
									end
									street_parts.delete_at(idx)
									break
								end
							end
							street = street_parts.join(" ")
						end
						return [country, zipcode, city, street, number]
					end

				end
			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Address)
