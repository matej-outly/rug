# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Abstract component 
# *
# * Author: Matěj Outlý
# * Date  : 2. 6. 2015
# *
# *****************************************************************************

module RugController
	class Component

		# *********************************************************************
		# Basic
		# *********************************************************************

		#
		# Constructor
		#
		def initialize
			self.config = RugController::ComponentConfig.new(self.class)
		end

		#
		# Controller setter
		#
		def controller=(controller)
			@controller = controller
		end

		#
		# Controller getter
		#
		def controller
			return @controller
		end

		#
		# Component reset method
		#
		def reset
		end

		#
		# Component control method
		#
		def control
		end

		#
		# Access instance variable defined in control method
		#
		def method_missing(method_name, *args)
			if instance_variable_defined?("@#{method_name}")
				return instance_variable_get("@#{method_name}")
			else
				return nil
			end
		end

		#
		# Get component namespace
		#
		def self.namespace
			return self.to_s.sub(/[^:]+$/, "").sub(/::$/, "") # Module name
		end

		#
		# Get component namespace
		#
		def namespace
			if @namespace.nil?
				@namespace = self.class.namespace
			end
			return @namespace
		end

		#
		# Get component name
		#
		def self.name
			return self.to_s.sub(/^.+::/, "").sub(/Component$/, "") # Class name without nomespace and "Component" suffix
		end

		#
		# Get component name
		#
		def name
			if @name.nil?
				@name = self.class.name
			end
			return @name
		end

		#
		# Get component path
		#
		def self.path
			return "#{self.namespace.to_snake}/#{self.name.to_snake}"
		end

		#
		# Get component path
		#
		def path
			return self.class.key
		end

		#
		# Path to component view template (constructed as partial)
		#
		def to_partial_path
			"components/#{namespace.to_snake}/#{name.to_snake}"
		end

		# *********************************************************************
		# Configuration
		# *********************************************************************

		#
		# Set config object
		#
		def config=(config)
			@config = config
		end

		#
		# Get config object (or some config option)
		#
		def config(*args)
			result = @config
			args.each do |key|
				if !result.nil?
					result = result[key.to_sym]
				end
			end
			return result
		end

		# *********************************************************************
		# Inbound broadcasts
		# *********************************************************************

		#
		# Get all implemented broadcasts
		#
		def self.implemented_broadcasts
			return @implemented_broadcasts
		end

		#
		# Get all implemented broadcasts
		#
		def implemented_broadcasts
			return self.class.implemented_broadcasts
		end

		#
		# Implements broadcast of this name?
		#
		def self.implements_broadcast?(name)
			return !@implemented_broadcasts.nil? && @implemented_broadcasts.key?(name)
		end

		#
		# Implements broadcast of this name?
		#
		def implements_broadcast?(name)
			return self.class.implements_broadcast?(name)
		end

		#
		# Register broadcast which can be processed by the component
		#
		def self.implement_broadcast(name)
			
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
			@broadcasts << Broadcast.new(name, self, arguments)
		end

		#
		# Clear all sended broadcasts
		#
		def clear_broadcasts
			@broadcasts.clear
		end

	end
end
