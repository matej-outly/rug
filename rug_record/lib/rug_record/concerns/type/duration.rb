# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Duration definition
# *
# * Author: Matěj Outlý
# * Date  : 16. 2. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Duration extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new enum column
					#
					def duration_column(new_column, options = {})
						
						# Days set method
						define_method((new_column.to_s + "_set").to_sym) do |new_days, new_hours, new_minutes, new_seconds|
							column = new_column
							current_days = self.send((column.to_s + "_days").to_sym).to_i
							current_hours = self.send((column.to_s + "_hours").to_sym).to_i
							current_minutes = self.send((column.to_s + "_minutes").to_sym).to_i
							current_seconds = self.send((column.to_s + "_seconds").to_sym).to_i
							value = DateTime.parse("2000-01-01 00:00:00 +0000")
							value += (!new_days.nil? ? new_days.to_i.days : current_days.days)
							value += (!new_hours.nil? ? new_hours.to_i.hours : current_hours.hours)
							value += (!new_minutes.nil? ? new_minutes.to_i.minutes : current_minutes.minutes)
							value += (!new_seconds.nil? ? new_seconds.to_i.seconds : current_seconds.seconds)
							self.send(column.to_s + "=", value)
						end

						# Days set method
						define_method((new_column.to_s + "_days=").to_sym) do |value|
							column = new_column
							self.send((column.to_s + "_set").to_sym, value, nil, nil, nil)
						end

						# Hours set method
						define_method((new_column.to_s + "_hours=").to_sym) do |value|
							column = new_column
							self.send((column.to_s + "_set").to_sym, nil, value, nil, nil)
						end

						# Minutes set method
						define_method((new_column.to_s + "_minutes=").to_sym) do |value|
							column = new_column
							self.send((column.to_s + "_set").to_sym, nil, nil, value, nil)
						end

						# Seconds set method
						define_method((new_column.to_s + "_seconds=").to_sym) do |value|
							column = new_column
							self.send((column.to_s + "_set").to_sym, nil, nil, nil, value)
						end

						# Days get method
						define_method((new_column.to_s + "_days").to_sym) do
							column = new_column
							value = read_attribute(column.to_s)
							return value.days_since_new_year if !value.nil?
							return nil
						end

						# Hours get method
						define_method((new_column.to_s + "_hours").to_sym) do
							column = new_column
							value = read_attribute(column.to_s)
							return value.hour if !value.nil?
							return nil
						end

						# Minutes get method
						define_method((new_column.to_s + "_minutes").to_sym) do
							column = new_column
							value = read_attribute(column.to_s)
							return value.min if !value.nil?
							return nil
						end

						# Seconds get method
						define_method((new_column.to_s + "_seconds").to_sym) do
							column = new_column
							value = read_attribute(column.to_s)
							return value.sec if !value.nil?
							return nil
						end

						# Get method
						define_method((new_column.to_s + "_formatted").to_sym) do
							column = new_column
							value = read_attribute(column.to_s)
							return nil if value.blank?
							days = value.days_since_new_year
							hours = value.hour
							minutes = value.min
							seconds = value.sec
							result = []
							result << days.to_s + " " + I18n.t("general.attribute.duration.days").downcase_first if days > 0
							result << hours.to_s + " " + I18n.t("general.attribute.duration.hours").downcase_first if hours > 0
							result << minutes.to_s + " " + I18n.t("general.attribute.duration.minutes").downcase_first if minutes > 0
							result << seconds.to_s + " " + I18n.t("general.attribute.duration.seconds").downcase_first if seconds > 0
							return result.join(", ")
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Duration)
