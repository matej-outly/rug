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
					def address_column(new_column)
					
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
							value = value.symbolize_keys.select { |key, value| [:street, :number, :postcode, :city].include?(key) } if !value.nil?
							
							# Store
							if value.blank?
								self.send("#{column.to_s}_street=", nil)
								self.send("#{column.to_s}_number=", nil)
								self.send("#{column.to_s}_postcode=", nil)
								self.send("#{column.to_s}_city=", nil)
							else
								self.send("#{column.to_s}_street=", value[:street])
								self.send("#{column.to_s}_number=", value[:number])
								self.send("#{column.to_s}_postcode=", value[:postcode])
								self.send("#{column.to_s}_city=", value[:city])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value_street = self.send("#{column.to_s}_street")
							value_number = self.send("#{column.to_s}_number")
							value_postcode = self.send("#{column.to_s}_postcode")
							value_city = self.send("#{column.to_s}_city")
							if value_street.blank? && value_number.blank? && value_postcode.blank? && value_city.blank?
								return nil
							else
								return { street: value_street, number: value_number, postcode: value_postcode, city: value_city, formatted: self.send((column.to_s + "_formatted").to_sym) }
							end
						end

						# Get method
						define_method((new_column.to_s + "_formatted").to_sym) do
							column = new_column
							value_street = self.send("#{column.to_s}_street")
							value_number = self.send("#{column.to_s}_number")
							value_postcode = self.send("#{column.to_s}_postcode")
							value_city = self.send("#{column.to_s}_city")
							if value_street.blank? && value_number.blank? && value_postcode.blank? && value_city.blank?
								return nil
							else
								return "#{value_street} #{value_number}, #{value_postcode} #{value_city}"
							end
						end

					end

					#
					# Parse address
					#
					def parse_address(address)
						country = nil
						city = nil
						street = nil
						number = nil
						address_parts = address.to_s.split(",").map { |i| i.trim(" ") }
						if address_parts.length >= 1
							country = address_parts.pop
						end
						if address_parts.length >= 1
							city = address_parts.pop
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
						return [country, city, street, number]
					end

				end
			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Address)
