# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Sorting
# *
# * Author: Matěj Outlý
# * Date  : 22. 6. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Sorting extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Sorting
				#
				def sorting(sort_column, default_order_columns = nil)
					
					# Default ordering for special cases
					if default_order_columns.nil?
						if ordered?
							default_order_columns = "position ASC"
						elsif hierarchically_ordered?
							default_order_columns = "lft ASC"
						else
							default_order_columns = "id ASC"
						end
					end

					# Convert to array
					if default_order_columns.is_a? String
						default_order_columns = [default_order_columns]
					end

					# Sorting
					if sort_column.nil?
						order_columns = default_order_columns
					else
						order_columns = ["#{sort_column.to_s} ASC"].concat(default_order_columns)
					end

					order(order_columns)
				end

			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Sorting)
