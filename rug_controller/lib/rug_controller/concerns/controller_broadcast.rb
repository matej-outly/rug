# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Outbound and inbound broadcasts support for controllers 
# *
# * Author: Matěj Outlý
# * Date  : 29. 7. 2015
# *
# *****************************************************************************

require "action_controller"

module RugController
	module Concerns
		module ControllerBroadcast extend ActiveSupport::Concern

			#
			# 'included do' causes the included code to be evaluated in the
			# context where it is included, rather than being executed in 
			# the module's context.
			#
			included do
			
				# Reset
				before_action do
					
					# Clear broadcasts
					clear_broadcasts

				end

			end

			module ClassMethods
				
				# *****************************************************************
				# Inbound broadcasts
				# *****************************************************************

				#
				# Get all implemented broadcasts
				#
				def implemented_broadcasts
					return @implemented_broadcasts
				end

				#
				# Implements broadcast of this name?
				#
				def implements_broadcast?(name)
					return !@implemented_broadcasts.nil? && @implemented_broadcasts.key?(name)
				end

				#
				# Register broadcast which can be processed by the controller
				#
				def implement_broadcast(name)
					
					# First implemented broadcast
					if @implemented_broadcasts.nil?
						@implemented_broadcasts = {}
					end

					# Multiple registration is not allowed
					if @implemented_broadcasts.key?(name)
						return false
					end

					# Register
					@implemented_broadcasts[name] = true
					
					return true
				end

			end

			# Instance methods ...

			# *********************************************************************
			# Inbound broadcasts
			# *********************************************************************

			#
			# Get all implemented broadcasts
			#
			def implemented_broadcasts
				return self.class.implemented_broadcasts
			end

			#
			# Implements broadcast of this name?
			#
			def implements_broadcast?(name)
				return self.class.implements_broadcast?(name)
			end

			#
			# Call broadcast which can be processed by the component
			#
			def call_implemented_broadcast(name, method, arguments)
				if implements_broadcast?(name)
					receive_callback = self.method(method)
					if receive_callback
						return receive_callback.call(arguments)
					else
						return nil
					end
				else
					return nil
				end
			end

			# *********************************************************************
			# Outbound broadcasts
			# *********************************************************************

			#
			# Send new broadcast message
			#
			def send_broadcast(name, arguments = nil)
				@broadcasts = [] if @broadcasts.nil?
				@broadcasts << RugController::Broadcast.new(name, self, arguments)
			end

			#
			# Forward all sent broadcasts
			#
			def forward_broadcasts
				@broadcasts = [] if @broadcasts.nil?
				result = @broadcasts.dup
				@broadcasts.clear
				return result
			end

			#
			# Clear all sended broadcasts
			#
			def clear_broadcasts
				@broadcasts = [] if @broadcasts.nil?
				@broadcasts.clear
			end

		end
	end
end

ActionController::Base.send(:include, RugController::Concerns::ControllerBroadcast)