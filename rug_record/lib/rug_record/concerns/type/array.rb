# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Array definition
# *
# * Author: Matěj Outlý
# * Date  : 4. 4. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Array extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new array column
					#
					def array_column(new_column, options = {})
					
						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column
							
							# Convert string to Array 
							if value.is_a?(::String)
								if !value.blank?
									value = JSON.parse(value) rescue nil
								else
									value = nil
								end
							end

							# Check type
							if !value.nil? && !value.is_a?(::Array)
								raise "Wrong value format, expecting Array or nil."
							end

							# Optional value filter
							if options[:filter]
								if !value.nil?
									value = value.map{ |item| options[:filter].call(item) }.compact
								end
							end
							
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
								begin
									return JSON.parse(value)
								rescue JSON::ParserError
									return nil
								end
							end
						end

					end

					#
					# Add new enum array column
					#
					def enum_array_column(new_column, spec, options = {})
						
						# Define it using array and enum
						array_column(new_column, options)
						enum_column(new_column, spec, options)

						# Objs method
						define_method((new_column.to_s + "_objs").to_sym) do
							column = new_column
							values = self.send(column)
							if values
								result = []
								values.each do |value|
									obj = self.class.enums[column][value.to_s]
									result << obj if obj
								end
								if result.empty?
									return nil
								else
									return result
								end
							else
								return nil
							end
						end

					end

					#
					# Add new parametrized enum array column
					#
					def parametrized_enum_array_column(new_column, spec, options = {})
						
						# Define it using enum array
						array_column(new_column, options)
						enum_column(new_column, spec, options)

						# Objs method
						define_method((new_column.to_s + "_objs").to_sym) do
							column = new_column
							parameters = options[:parameters] ? options[:parameters] : 1 # Number of parameters
							values = self.send(column)
							if values
								result = []
								values.each do |value|
									obj = self.class.enums[column][value.first.to_s]
									if obj
										duplicate = obj.dup
										(1..parameters).each do |parameter_index|
											if parameter_index == 1
												duplicate.parameter = value[parameter_index]
											else
												duplicate.send("parameter_#{parameter_index}=", value[parameter_index])
											end
										end
										result << duplicate
									end
								end
								if result.empty?
									return nil
								else
									return result
								end
							else
								return nil
							end
						end

						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column
							parameters = options[:parameters] ? options[:parameters] : 1 # Number of parameters
							
							# Convert string to Array 
							if value.is_a?(::String)
								if !value.blank?
									value = JSON.parse(value) rescue nil
								else
									value = nil
								end
							end

							# Check type
							if !value.nil? && !value.is_a?(::Array)
								raise "Wrong value format, expecting Array or nil."
							end
							
							# Store
							if value.blank?
								write_attribute(column.to_sym, nil)
							else

								# Normalize format to contain array of 2-item arrays
								new_value = []
								value.each do |item|
									item = [item.to_s] if !item.is_a?(::Array)
									item = item[0..parameters] # Cut to max (number of parameters + 1) items
									item << nil while item.length < (parameters + 1) # Ensure length == number of parameters + 1
									item = item.map{ |value| value.nil? ? "" : value }
									new_value << item
								end
								value = new_value

								write_attribute(column.to_sym, value.to_json)
							end
						end

					end

					#
					# Add new hash array column
					#
					def hash_array_column(new_column, attributes, options = {})
						raise "Wrong attributes format, expecting Array." if !attributes.is_a?(::Array)
						attributes = attributes.map { |attribute| attribute.to_s }
						
						# Filter only hash with valid attributes
						options[:filter] = lambda do |item| 
							if item.is_a?(Hash) 
								result = item.stringify_keys.select { |key, value| attributes.include?(key) }
								result = nil if result.empty?
							else
								result = nil
							end
							result
						end

						# Define with standard array column
						array_column(new_column, options)
					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Array)
