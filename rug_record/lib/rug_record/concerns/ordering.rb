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
					acts_as_ordered(column)

					# Ordering if new 
					before_create do
						if self.send(column).nil?
							assign_attributes({ column => self.class.count + 1 })
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
				if self.position <= destination.position
					position = destination.position
				else
					position = destination.position + 1
				end
				move_to_position(position)
			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Ordering)