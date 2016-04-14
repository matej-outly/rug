# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Geopolygon definition
# *
# * Author: Matěj Outlý
# * Date  : 24. 11. 2015
# *
# *****************************************************************************

require "active_record"
require "geometry"
require "clipper"

module RugRecord
	module Concerns
		module Type
			module Geopolygon extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new geopolygon column
					#
					def geopolygon_column(new_column)
					
						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column
							
							puts value.inspect

							# Convert string to Hash 
							if value.is_a? ::String
								if !value.blank?
									value = JSON.parse(value)
								else
									value = nil
								end
							end

							puts value.inspect

							# Check type
							if !value.nil? && !value.is_a?(::Array)
								raise "Wrong value format, expecting Array or nil."
							end
							
							# Store
							if value.blank?
								self.send("#{column.to_s}_points=", nil)
								self.send("#{column.to_s}_top=", nil)
								self.send("#{column.to_s}_bottom=", nil)
								self.send("#{column.to_s}_left=", nil)
								self.send("#{column.to_s}_right=", nil)
							else
								
								# Iterate input, check format and retrieve wrapping rectangle
								points = []
								top = nil
								bottom = nil
								left = nil
								right = nil
								value.each do |point|
									if !point.is_a?(::Array) || point.length != 2
										raise "Wrong value format, expecting Array of points (two-item array)."
									end
									latitude = point[0].to_f
									longitude = point[1].to_f
									points << [latitude, longitude]
									if top.nil? || latitude > top
										top = latitude
									end
									if bottom.nil? || latitude < bottom
										bottom = latitude
									end
									if right.nil? || longitude > right
										right = longitude
									end
									if left.nil? || longitude < left
										left = longitude
									end
								end

								# Write attributes
								self.send("#{column.to_s}_points=", points.to_json)
								self.send("#{column.to_s}_top=", top)
								self.send("#{column.to_s}_bottom=", bottom)
								self.send("#{column.to_s}_left=", left)
								self.send("#{column.to_s}_right=", right)
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							value = self.send("#{column.to_s}_points")
							if value.blank?
								return nil
							else
								return JSON.parse(value)
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

							# Get self polygon
							value = self.send(new_column.to_sym)
							if value.nil?
								return true
							end

							if bottom.nil? || right.nil? # Point

								# Get latitude and longitude
								latitude = top 
								longitude = left

								# Not defined
								if latitude.blank? || longitude.blank?
									return true
								end

								# Perform check
								check_point = Geometry::Point[latitude, longitude]
								check_polygon = Geometry::Polygon.new(*value)
								return ((check_polygon <=> check_point) != -1)
								
							else # Rectangle

								# Not defined
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
								clipper = Clipper::Clipper.new
								clipper.add_subject_polygon(value)
								clipper.add_clip_polygon([[top,left],[top,right],[bottom,right],[bottom,left]])
								return !clipper.intersection.empty?

							end # Rectangle

						end # Check method

					end # geopolygon_column

				end # ClassMethods

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Geopolygon)
