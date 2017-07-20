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
					def georectangle_column(new_column, options = {})
					
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
								self.send("#{column.to_s}_top=", nil)
								self.send("#{column.to_s}_bottom=", nil)
								self.send("#{column.to_s}_left=", nil)
								self.send("#{column.to_s}_right=", nil)
							else
								self.send("#{column.to_s}_top=", value[:top])
								self.send("#{column.to_s}_bottom=", value[:bottom])
								self.send("#{column.to_s}_left=", value[:left])
								self.send("#{column.to_s}_right=", value[:right])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value_top = self.send("#{column.to_s}_top")
							value_bottom = self.send("#{column.to_s}_bottom")
							value_left = self.send("#{column.to_s}_left")
							value_right = self.send("#{column.to_s}_right")
							if value_top.blank? || value_bottom.blank? || value_left.blank? || value_right.blank?
								return nil
							else
								return { top: value_top, bottom: value_bottom, left: value_left, right: value_right }
							end
						end

						# Get method
						define_method((new_column.to_s + "_formated").to_sym) do
							column = new_column
							value_top = self.send("#{column.to_s}_top")
							value_bottom = self.send("#{column.to_s}_bottom")
							value_left = self.send("#{column.to_s}_left")
							value_right = self.send("#{column.to_s}_right")
							if value_top.blank? || value_bottom.blank? || value_left.blank? || value_right.blank?
								return nil
							else
								return "#{value_top}, #{value_bottom}, #{value_left}, #{value_right}"
							end
						end

						# Search method
						define_singleton_method((new_column.to_s + "_intersection").to_sym) do |top, left, bottom = nil, right = nil|
							column = new_column

							# Point => rectangle transformation
							bottom = top if bottom.nil?
							right = left if right.nil?

							if top.blank? || bottom.blank? || left.blank? || right.blank?
								all
							else

								# Normalize params
								top = top.to_f
								bottom = bottom.to_f
								left = left.to_f
								right = right.to_f

								# Normalize rectangle
								if top < bottom
									tmp = top
									top = bottom
									bottom = tmp
								end
								if right < left
									tmp = right
									right = left
									left = tmp
								end

								# Condition (rectangle intersection)
								where(
									":left <= #{column}_right" + " AND " + 
									":right >= #{column}_left" + " AND " + 
									":bottom <= #{column}_top" + " AND " + 
									":top >= #{column}_bottom",
									top: top,
									bottom: bottom,
									left: left,
									right: right
								)
							end
						end # Search method

						# Check method
						define_method((new_column.to_s + "_intersection?").to_sym) do |top, left, bottom = nil, right = nil|
							column = new_column

							# Point => rectangle transformation
							bottom = top if bottom.nil?
							right = left if right.nil?

							if top.blank? || bottom.blank? || left.blank? || right.blank?
								return true
							end

							# Normalize params
							top = top.to_f
							bottom = bottom.to_f
							left = left.to_f
							right = right.to_f

							# Normalize rectangle
							if top < bottom
								tmp = top
								top = bottom
								bottom = tmp
							end
							if right < left
								tmp = right
								right = left
								left = tmp
							end

							# Read values
							value_top = self.send("#{column.to_s}_top")
							value_bottom = self.send("#{column.to_s}_bottom")
							value_left = self.send("#{column.to_s}_left")
							value_right = self.send("#{column.to_s}_right")

							# Perform check
							return (left <= value_right) && (right >= value_left) && (bottom <= value_top) && (top >= value_bottom)
							
						end # Check method

					end # georectangle_column

				end # ClassMethods

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Georectangle)
