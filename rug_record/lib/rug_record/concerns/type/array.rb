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
							if value.is_a? ::String
								if !value.blank?
									value = JSON.parse(value)
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

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Array)
