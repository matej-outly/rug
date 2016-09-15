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
							if !item.is_a? Hash
								item = { value: item.to_s }
							end
							if !item[:value]
								raise "State definition cannot be empty."
							end
							if !item[:label]
								item[:label] = I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{new_column.to_s}_values.#{item[:value]}")
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
