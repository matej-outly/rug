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
		module Array extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Add new enum column
				#
				def array_column(new_column)
				
					# Set method
					define_method((new_column.to_s + "=").to_sym) do |array|
						column = new_column
						if array.is_a? ::String
							array = JSON.parse(array)
						end
						if array.is_a? ::Array
							write_attribute(column.to_sym, array.to_json)
						else
							raise "Wrong array format, expecting Array"
						end
					end

					# Get method
					define_method(new_column.to_sym) do
						column = new_column
						array = read_attribute(column.to_sym)
						if array.blank?
							return nil
						else
							return JSON.parse(array)
						end
					end

					# Get method
					define_method((new_column.to_s + "_formated").to_sym) do
						column = new_column
						array = send(column.to_sym)
						if array.blank?
							return nil
						else
							return array.join(", ")
						end
					end

				end

			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Array)
