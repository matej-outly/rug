# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Store definition
# *
# * Author: Matěj Outlý
# * Date  : 15. 2. 2016
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Store extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new store column
					#
					def store_column(new_column, options = {})
						
						# Attributes
						store_values_attr = "#{new_column.to_s}_values"
						store_order_attr = "#{new_column.to_s}_order"

						# Define store values with _values attribute
						store_accessor store_values_attr

						# Define store ordering with _order attribute
						array_column store_order_attr

						# Define getter and setter respecting ordering defined in _order array
						
						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column
							
							if value.blank?
								send("#{store_values_attr}=", nil)
								send("#{store_order_attr}=", nil)
							elsif value.is_a?(Hash)
								send("#{store_values_attr}=", value)
								send("#{store_order_attr}=", value.keys)
							else
								raise "Wrong value format, expecting Hash or nil."
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column

							store_values = send(store_values_attr)
							store_order = send(store_order_attr)
							if store_values.blank? || store_order.blank?
								return nil
							else

								# For some fucking weird reason is_a?(Array) method don't work correctly...
								if !(store_order.class.name == "Array") || !store_values.is_a?(Hash)
									raise "Data in DB corrupted - values must be hstore and order must be array." 
								end
								result = {}
								store_order.each do |key| # Give result in correct order
									result[key] = store_values[key]
								end
								return result
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Store)
