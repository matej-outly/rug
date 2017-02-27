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
								#send("#{store_order_attr}=", nil) # TMP
							elsif value.is_a?(Hash)
								send("#{store_values_attr}=", value)
								#send("#{store_order_attr}=", value.keys) # TMP
							else
								raise "Wrong value format, expecting Hash or nil."
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column

							return send(store_values_attr) # TMP
#							values = send(store_values_attr)
#							order = send(store_order_attr)
#							if values.blank? || order.blank?
#								return nil
#							else
#								if !order.is_a?(Array) || !values.is_a?(Hash)
#									raise "Data in DB corrupted - values must be hstore and order must be array." 
#								end
#								result = {}
#								order.each do |key| # Give result in correct order
#									result[key] = values[key]
#								end
#								return result
#							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Store)
