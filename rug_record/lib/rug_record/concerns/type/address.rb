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
					# Add new enum column
					#
					def address_column(new_column)
					
						# Set method
						define_method((new_column.to_s + "=").to_sym) do |address|
							column = new_column
							if address.is_a? ::String
								if !address.blank?
									address = JSON.parse(address)
								else
									address = nil
								end
							end
							if address.nil?
								write_attribute(column.to_sym, nil)
							elsif address.is_a? Hash
								write_attribute(column.to_sym, address.to_json)
							else
								raise "Wrong address format, expecting Hash"
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							address = read_attribute(column.to_sym)
							if address.blank?
								return nil
							else
								return JSON.parse(address)
							end
						end

						# Get method
						define_method((new_column.to_s + "_formated").to_sym) do
							column = new_column
							address = send(column.to_sym)
							if address.blank?
								return nil
							else
								return "#{address["street"]} #{address["number"]}, #{address["postcode"]} #{address["city"]}"
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Address)
