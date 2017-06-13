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

					#
					# Move object to relation with other object
					#
					# Relations:
					# - right ... move right of destination object
					# - left  ... move left of destination object
					# - child ... move as FIRST child of destination object
					# - child_first ... move as first child of destination object
					# - child_last  ... move as last child of destination object
					#
					define_singleton_method(:move) do |moved_id, relation, destination_id|
						moved_object = find_by_id(moved_id)
						destination_object = find_by_id(destination_id)
						if moved_object && destination_object
							if relation.to_sym == :right
								return moved_object.move_to_right_of(destination_object)
							elsif relation.to_sym == :left
								return moved_object.move_to_left_of(destination_object)
							elsif relation.to_sym == :child || relation.to_sym == :child_first
								first_child = destination_object.children.first
								if first_child
									return moved_object.move_to_left_of(first_child)
								else
									return moved_object.move_to_child_of(destination_object)
								end
							elsif relation.to_sym == :child_last
								return moved_object.move_to_child_of(destination_object)
							else
								return false
							end
						else
							return false
						end
					end

					#
					# Get maximal level of existing nodes
					#
					define_singleton_method(:maximal_level) do
						return maximum("depth").to_i
					end

					#
					# Create JSON (string) representation of the hierarchical tree. 
					# Collection of objects ordered by lft can be passed.
					#
					define_singleton_method(:to_hierarchical_json) do |objects = nil|
						return ActiveSupport::JSON.encode(as_hierarchical_json(objects))
					end

					#
					# Create JSON (object) representation of the hierarchical tree. 
					# Collection of objects ordered by lft can be passed.
					#
					define_singleton_method(:as_hierarchical_json) do |objects = nil|
						
						# Default objects
						objects = all.order(lft: :asc) if objects.nil?
						
						# Empty selection
						return nil if objects.size == 0

						# preset path with fake parent
						path = [{id: objects.first.parent_id}]

						last_object_as_json = nil
						objects.each do |object|
							
							# Check if new level => have we descened or ascened? Then update path (and context) accordingly
							if object.parent_id != path.last[:id] 
								if path.map{ |i| i[:id] }.include?(object.parent_id) # We ascended
									path.pop while path.last[:id] != object.parent_id # Remove the wrong trailing path elements
								else # We descended
									path << last_object_as_json
								end
							end

							# Save object to next iteration where can be added to path as parent
							last_object_as_json = object.as_json.symbolize_keys

							# Add object to current context (= last item in path)
							path.last[:children] = [] if path.last[:children].nil?
							path.last[:children] << last_object_as_json

						end
						
						# Result
						return path.first[:children]
					end

					#
					# Get all available parents
					#
					define_method(:available_parents) do
						if self.new_record?
							self.class.all.order(lft: :asc)
						else
							self.class.where("id <> :id", id: self.id).order(lft: :asc)
						end
					end

				end

				#
				# Is this model hierachically ordered?
				#
				def hierarchically_ordered?
					return (@hierarchically_ordered == true)
				end

				#
				# Iterate over all hierarchical items including fake (dummy) root
				#
				def each_plus_dummy_with_level(objects, &block)
					path = [nil]
					objects.each do |o|
						if o.parent_id != path.last
							# We are on a new level, did we descend or ascend?
							if path.include?(o.parent_id)
								path.pop while path.last != o.parent_id # Remove wrong tailing paths elements
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

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::HierarchicalOrdering)