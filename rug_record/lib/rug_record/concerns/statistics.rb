# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Statistics
# *
# * Author: Matěj Outlý
# * Date  : 22. 6. 2015
# *
# *****************************************************************************

require "active_record"
require "groupdate"

module RugRecord
	module Concerns
		module Statistics extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Group by flexible date range
				#
				def group_by_flexible_date_range(group_column, from_date = nil, to_date = nil, options = {})
					
					# Default range
					if options[:default_range]
						default_range = options[:default_range]
					else
						default_range = 1.year
					end

					# Deal with nil dates
					to_date = Date.today if to_date.nil?
					from_date = to_date - default_range if from_date.nil?

					# Correct format
					from_date = Date.parse(from_date.to_s) if !from_date.is_a?(Date)
					to_date = Date.parse(to_date.to_s) if !to_date.is_a?(Date)

					# Correct causality
					if from_date > to_date
						tmp = from_date
						from_date = to_date
						to_date = tmp
					end

					# Calculate period
					date_range = (to_date - from_date).to_i.days
					if date_range > 4.years
						period = :year
					elsif date_range > 10.months
						period = :month
					elsif date_range > 6.weeks
						period = :week
					elsif date_range > 2.days
						period = :day
					else
						period = :hour
					end

					# call groupdate
					group_by_period(period, group_column, range: from_date..to_date)
				end

			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Statistics)