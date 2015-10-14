# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Georectangle definition
# *
# * Author: Matěj Outlý
# * Date  : 13. 10. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Georectangle extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new georectangle column
					#
					def georectangle_column(new_column)
					
						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column
							
							# Convert string to Hash 
							if value.is_a? ::String
								if !value.blank?
									value = JSON.parse(value)
								else
									value = nil
								end
							end

							# Check type
							if !value.nil? && !value.is_a?(Hash)
								raise "Wrong value format, expecting Hash or nil."
							end

							# Filter and symbolize keys
							value = value.symbolize_keys.select { |key, value| [:top, :bottom, :left, :right].include?(key) } 
							
							# Store
							if value.blank? || value[:top].blank? || value[:bottom].blank? || value[:left].blank? || value[:right].blank?
								write_attribute("#{column.to_s}_top", nil)
								write_attribute("#{column.to_s}_bottom", nil)
								write_attribute("#{column.to_s}_left", nil)
								write_attribute("#{column.to_s}_right", nil)
							else
								write_attribute("#{column.to_s}_top", value[:top])
								write_attribute("#{column.to_s}_bottom", value[:bottom])
								write_attribute("#{column.to_s}_left", value[:left])
								write_attribute("#{column.to_s}_right", value[:right])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value_top = read_attribute("#{column.to_s}_top")
							value_bottom = read_attribute("#{column.to_s}_bottom")
							value_left = read_attribute("#{column.to_s}_left")
							value_right = read_attribute("#{column.to_s}_right")
							if value_top.blank? || value_bottom.blank? || value_left.blank? || value_right.blank?
								return nil
							else
								return { top: value_top, bottom: value_bottom, left: value_left, right: value_right }
							end
						end

						# Get method
						define_method((new_column.to_s + "_formated").to_sym) do
							column = new_column
							value_top = read_attribute("#{column.to_s}_top")
							value_bottom = read_attribute("#{column.to_s}_bottom")
							value_left = read_attribute("#{column.to_s}_left")
							value_right = read_attribute("#{column.to_s}_right")
							if value_top.blank? || value_bottom.blank? || value_left.blank? || value_right.blank?
								return nil
							else
								return "#{value_top}, #{value_bottom}, #{value_left}, #{value_right}"
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Georectangle)
