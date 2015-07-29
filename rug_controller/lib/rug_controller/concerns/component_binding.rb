# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Binding of components to controller 
# *
# * Author: Matěj Outlý
# * Date  : 2. 6. 2015
# *
# *****************************************************************************

require "action_controller"

module RugController
	module Concerns
		module ComponentBinding extend ActiveSupport::Concern

			#
			# 'included do' causes the included code to be evaluated in the
			# context where it is included, rather than being executed in 
			# the module's context.
			#
			included do
			
				# Process all broadcasts
				after_action do
					
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

			module ClassMethods
				
				@@pooled_components = {}

				#
				# Define component
				#
				def component(component_class)

					# Normalize component class
					if component_class.is_a? String
						component_class = component_class.constantize
					end

					# Component pool
					if self.pooled_components[component_class.path].nil?
						self.pooled_components[component_class.path] = component_class.new
					end
					
					# Set component as instance variable, reset and control it
					before_action do
						
						# Integrate component to controller
						component = self.class.pooled_components[component_class.path]
						self.active_components[component_class.path] = component
						self.instance_variable_set("@#{component_class.name.to_snake}", component)
						component.controller = self

						# Control component
						component.reset
						component.control
					end

				end

				#
				# Get pooled components
				#
				def pooled_components
					return @@pooled_components
				end

			end

			# Instance methods ...

			#
			# Get all active components
			#
			def active_components
				@active_components = {} if @active_components.nil?
				return @active_components
			end

		end
	end
end

ActionController::Base.send(:include, RugController::Concerns::ComponentBinding)