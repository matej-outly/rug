# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * State definition
# *
# * Author: Matěj Outlý
# * Date  : 15. 2. 2016
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module State extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new state column
					#
					def state_column(new_column, spec, options = {})
						
						# Prepare internal structure
						if @states.nil?
							@states = {}
						end
						@states[new_column] = {}

						# Fill out internal structure
						spec.each do |item|

							# Value check
							if !item.is_a? Hash
								item = { value: item.to_s }
							end
							if !item[:value]
								raise "State definition cannot be empty."
							end

							# Identify special type
							special_type = nil
							if item[:value].is_a?(Integer)
								special_type = "integer"
							end

							# Label
							if !item[:label]
								item[:label] = I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{new_column.to_s}_values.#{item[:value]}")
							end

							# Other attributes
							if options[:attributes]
								options[:attributes].each do |attribute|
									singular_attribute_name = attribute.to_s.singularize
									plural_attribute_name = attribute.to_s.pluralize
									item[singular_attribute_name.to_sym] = I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{new_column.to_s}_#{plural_attribute_name}.#{special_type ? special_type + "_" : ""}#{item[:value]}")
								end
							end

							@states[new_column][item[:value].to_s] = OpenStruct.new(item)
						end

						# Obj method
						define_method((new_column.to_s + "_obj").to_sym) do
							column = new_column
							return self.class.states[column][self.send(column).to_s]
						end

						# All method
						define_singleton_method(("available_" + new_column.to_s.pluralize).to_sym) do
							column = new_column
							return @states[column].values
						end

						# All values method
						define_singleton_method(("available_" + new_column.to_s + "_values").to_sym) do
							column = new_column
							return @enums[column].values.map{ |o| o.value.to_sym }
						end

						# Label method
						define_singleton_method((new_column.to_s + "_label").to_sym) do |value|
							column = new_column
							return @enums[column].values.select{ |o| o.value.to_s == value.to_s }.map{ |o| o.label }.first
						end

						# Default value
						if options[:default]
							before_validation do
								column = new_column
								default = options[:default]
								if self.send(column).nil?
									self.send(column.to_s + "=", default.to_s)
								end
							end
						end

					end

					#
					# Add ne state transition
					#
					def state_transition(column, from_state, to_states)
						
					end

					#
					# Get all defined states 
					#
					def states
						return @states
					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::State)
