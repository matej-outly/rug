# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Enum definition
# *
# * Author: Matěj Outlý
# * Date  : 7. 1. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Enum extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Add new enum column
				#
				def enum_column(new_column, spec)
					
					# Prepare internal structure
					if @enums.nil?
						@enums = {}
					end
					@enums[new_column] = {}

					# Fill out internal structure
					spec.each do |item|
						if !item.is_a? Hash
							item = { value: item.to_s }
						end
						if item.empty?
							raise "Enum definition cannot be empty."
						end
						@enums[new_column][item.values.first] = OpenStruct.new(item)
					end

					# Obj method
					define_method((new_column.to_s + "_obj").to_sym) do
						column = new_column
						return self.class.enums[column][self.send(column)]
					end

					# All method
					define_singleton_method(("available_" + new_column.to_s.pluralize).to_sym) do
						column = new_column
						return @enums[column].values
					end

				end

				#
				# Get all defined enums 
				#
				def enums
					return @enums
				end

			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Enum)
