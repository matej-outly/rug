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
		module Type
			module Enum extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new enum column
					#
					def enum_column(new_column, spec, options = {})
						
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
							if !item[:value]
								raise "Enum definition cannot be empty."
							end
							if !item[:label]
								item[:label] = I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{new_column.to_s}_values.#{item[:value]}")
							end
							@enums[new_column][item[:value].to_s] = OpenStruct.new(item)
						end

						# Obj method
						define_method((new_column.to_s + "_obj").to_sym) do
							column = new_column
							return self.class.enums[column][self.send(column).to_s]
						end

						# All method
						define_singleton_method(("available_" + new_column.to_s.pluralize).to_sym) do
							column = new_column
							return @enums[column].values
						end

						# Default value
						if options[:default]
							before_create do
								column = new_column
								default = options[:default]
								if self.send(column).nil?
									self.send(column.to_s + "=", default.to_s)
								end
							end
						end

					end

					#
					# Get all defined enums 
					#
					def enums
						return @enums
					end

					#
					# Check if given column is enum defined on this model
					#
					def has_enum?(column)
						return !@enums.nil? && !@enums[column].nil?
					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Enum)
