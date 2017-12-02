# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Controller and components life cycle
# *
# * Author: Matěj Outlý
# * Date  : 30. 7. 2015
# *
# *****************************************************************************

require "action_controller"

module RugController
	module Concerns
		module Lifecycle extend ActiveSupport::Concern

			def render(*args)
				process_broadcasts
				super
			end

		protected

			def process_broadcasts
				
				# Preset
				sent_broadcasts = []

				# Gather all sent broadcasts together
				sent_broadcasts.concat(self.forward_broadcasts)
				self.active_components.each do |component_path, component|
					sent_broadcasts.concat(component.forward_broadcasts)
				end

				# --- All broadcasts are gathered together ---

				# Receive all broadcasts with all components and controller and call back to sender
				sent_broadcasts.each do |broadcast|
					
					# Receive message by controller and all components
					broadcast.receive(self)
					self.active_components.each do |component_path, component|
						broadcast.receive(component)
					end

					# Finish broadcast process with callback
					broadcast.callback
				end

			end

		end
	end
end

ActionController::Base.send(:include, RugController::Concerns::Lifecycle)