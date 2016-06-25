# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * ActiveRecord ordering
# *
# * Author: Matěj Outlý
# * Date  : 2. 11. 2014
# *
# *****************************************************************************

require "active_record"
require "ordered-active-record"

module RugRecord
	module Concerns
		module Ordering extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Define ordering
				#
				def enable_ordering
					
					# Column
					column = :position

					# => ordered-active-record
					#acts_as_ordered(column)

					# Ordering if new 
					before_create do
						if self.send(column).nil?
							#assign_attributes({ column => self.class.count + 1 })
						end
					end

					# Mark as ordered
					@ordered = true
				end

				#
				# Is this model ordered?
				#
				def ordered?
					return (@ordered == true)
				end

				#
				# Move object to relation with other object
				#
				def move(moved_id, relation, destination_id)
					moved_object = find_by_id(moved_id)
					destination_object = find_by_id(destination_id)
					if moved_object && destination_object
						if relation.to_sym == :succ
							return moved_object.move_to_right_of(destination_object)
						elsif relation.to_sym == :pred
							return moved_object.move_to_left_of(destination_object)
						else
							return false
						end
					else
						return false
					end
				end

			end

			# Instance methods ...

			#
			# Is this model ordered?
			#
			def ordered?
				return self.class.ordered?
			end

			#
			# Move to specific position
			#
			def move_to_position(position)
				update_attributes(position: position)
			end

			#
			# Move before some other node
			#
			def move_to_left_of(destination)
				return if self.position.nil? || destination.position.nil?
				if self.position < destination.position
					position = destination.position - 1
				else
					position = destination.position
				end
				move_to_position(position)
			end
			
			#
			# Move before some other node
			#
			def move_to_right_of(destination)
				return if self.position.nil? || destination.position.nil?
				if self.position <= destination.position
					position = destination.position
				else
					position = destination.position + 1
				end
				move_to_position(position)
			end

			#
			# Get next in order
			#
			def next_in_order
				next_model = self.class.where("position > ?", self.position).order(position: :asc).limit(1).first
				next_model ||= self.class.order(position: :asc).first
				return next_model
			end

			#
			# Get previous in order
			#
			def prev_in_order
				prev_model = self.class.where("position < ?", self.position).order(position: :desc).limit(1).first
				prev_model ||= self.class.order(position: :asc).last
				return prev_model
			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Ordering)