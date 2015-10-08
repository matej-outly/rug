# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * ActiveRecord hierarchical ordering
# *
# * Author: Matěj Outlý
# * Date  : 26. 11. 2014
# *
# *****************************************************************************

require "active_record"
require "awesome_nested_set"

module RugRecord
	module Concerns
		module HierarchicalOrdering extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Define ordering
				#
				def enable_hierarchical_ordering
					
					# => awesome_nested_set
					acts_as_nested_set(depth_column: :depth)

					# Mark as ordered
					@hierarchically_ordered = true

					# Set privilege checker
					#around_move :check_update_event

				end

				#
				# Is this model hierachically ordered?
				#
				def hierarchically_ordered?
					return (@hierarchically_ordered == true)
				end

				#
				# Get maximal level of existing nodes
				#
				def maximal_level
					return maximum("depth").to_i
				end

				def each_plus_dummy_with_level(objects, &block)
					path = [nil]
					objects.each do |o|
						if o.parent_id != path.last
							# we are on a new level, did we descend or ascend?
							if path.include?(o.parent_id)
								# remove wrong tailing paths elements
								path.pop while path.last != o.parent_id
							else
								path << o.parent_id
							end
						end
						block.call(o, path.length - 1)
					end
					block.call(nil, 0)
				end

			end

			# Instance methods ...
			
			#
			# Is this model hierachically ordered?
			#
			def hierarchically_ordered?
				return self.class.hierarchically_ordered?
			end

			#
			# Get all available parents
			#
			def available_parents
				if self.new_record?
					self.class.all.order(lft: :asc)
				else
					self.class.where("id <> :id", id: self.id).order(lft: :asc)
				end
			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::HierarchicalOrdering)