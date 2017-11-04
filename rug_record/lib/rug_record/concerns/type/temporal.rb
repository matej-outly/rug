# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Temporal definition
# *
# * Author: Matěj Outlý
# * Date  : 4. 11. 2017
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Temporal extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new temporal column
					#
					def temporal_column(new_column, options = {})
						define_method((new_column.to_s + "=").to_sym) do |value|
							temporal_set(new_column, value)
						end
						define_method(new_column.to_sym) do
							return temporal_get(new_column, value)
						end
					end

					#
					# Add new temporal integer column
					#
					def temporal_integer_column(new_column, options = {})
						define_method((new_column.to_s + "=").to_sym) do |value|
							temporal_set(new_column, value.nil? ? nil : value.to_i)
						end
						define_method(new_column.to_sym) do
							result = temporal_get(new_column)
							return (result.nil? ? nil : result.to_i)
						end
					end

					#
					# Add new temporal double column
					#
					def temporal_double_column(new_column, options = {})
						define_method((new_column.to_s + "=").to_sym) do |value|
							temporal_set(new_column, value.nil? ? nil : value.to_f)
						end
						define_method(new_column.to_sym) do
							result = temporal_get(new_column)
							return (result.nil? ? nil : result.to_f)
						end
					end

					#
					# Add new temporal float column
					#
					def temporal_float_column(new_column, options = {})
						define_method((new_column.to_s + "=").to_sym) do |value|
							temporal_set(new_column, value.nil? ? nil : value.to_f)
						end
						define_method(new_column.to_sym) do
							result = temporal_get(new_column)
							return (result.nil? ? nil : result.to_f)
						end
					end

				end

				def temporal_date
					@temporal_date = Date.today if @temporal_date.nil?
					return @temporal_date
				end

				def temporal_date=(value)
					@temporal_date = value
				end

			protected

				def temporal_set(column, value)
					
					# Load history (by parsing attribute value)
					history = self.read_attribute(column)
					if history.blank?
						history = nil
					else
						begin
							history = JSON.parse(history)
						rescue JSON::ParserError
							history = nil
						end
					end

					# Preset
					history = {} if !history.is_a?(Hash)

					# Set value
					history[self.temporal_date.to_s] = value

					# Optimization can be done here: similar values in the 
					# neighbouring intervals can be merged into a single 
					# interval...

					# Save JSON representation
					write_attribute(column, history.to_json)

					return value
				end

				def temporal_get(column)
					
					# Load history (by parsing attribute value)
					history = self.read_attribute(column)
					if history.blank?
						history = nil
					else
						begin
							history = JSON.parse(history)
						rescue JSON::ParserError
							history = nil
						end
					end

					if history.is_a?(Hash)

						# Find valid interval
						needle = self.temporal_date.to_s
						haystack = history.keys
						lo_bound = 0
						hi_bound = haystack.length - 1
						found = false
						needle_index = nil
						while !found do
							if lo_bound - 1 == hi_bound # section is empty
								found = true
							elsif lo_bound == hi_bound # section has exactly 1 element
								found = true
								if needle >= haystack[lo_bound]
									needle_index = lo_bound
								end
							else # section has 2 and more elements
								md_bound = (lo_bound + hi_bound + 1) / 2
								if needle < haystack[md_bound]
									hi_bound = md_bound - 1
								else # needle >= haystack[md_bound]
									lo_bound = md_bound
								end
							end
						end
						
						if needle_index
							return history[haystack[needle_index]]
						else
							return nil
						end
					else
						return nil
					end
				end

				def temporal_clean(column)
					self.write_attribute(column, nil)
				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Temporal)
