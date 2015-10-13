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
							value = value.select { |key, value| ["street", "number", "postcode", "city"].include?(key.to_s) } if !value.nil?
							
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
								return "#{value["street"]} #{value["number"]}, #{value["postcode"]} #{value["city"]}"
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Address)
