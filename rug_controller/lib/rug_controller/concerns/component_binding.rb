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

module RugController
	module Concerns
		module ComponentBinding extend ActiveSupport::Concern

			module ClassMethods
				
				@@component_pool = {}

				#
				# Define component
				#
				def component(component_class)
					
					# Normalize component class
					if component_class.is_a? String
						component_class = component_class.constantize
					end

					# Component pool
					if self.component_pool[component_class.path].nil?
						self.component_pool[component_class.path] = component_class.new
					end
					
					# Set component as instance variable, reset and control it
					before_action do
						component = self.class.component_pool[component_class.path]
						self.instance_variable_set("@#{component_class.name.to_snake}", component)
						component.reset
						component.control
					end

				end

				#
				# Get component pool
				#
				def component_pool
					return @@component_pool
				end

			end

			# Instance methods ...

		end
	end
end

ActionController::Base.send(:include, RugController::Concerns::ComponentBinding)