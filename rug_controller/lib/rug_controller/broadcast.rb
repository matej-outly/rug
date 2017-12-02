# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Component / controller broadcast message
# *
# * Author: Matěj Outlý
# * Date  : 15. 5. 2014
# *
# *****************************************************************************

module RugController
	class Broadcast

		#
		# Constructor
		#
		def initialize(name, sender, arguments)
			
			# Basic
			@name = name
			@sender = sender
			@arguments = arguments
			@results = []

			# Method names
			@callback_method = ("callback_" + name.to_s.to_snake).to_sym
			@receive_method = ("receive_" + name.to_s.to_snake).to_sym

		end

		#
		# Receive broadcast by given component or controller
		#
		def receive(receiver)
			if receiver.implements_broadcast?(@name)
				result = receiver.call_implemented_broadcast(@name, @receive_method, @arguments)
				if !result.nil?
					@results << result
				end
			end
		end

		#
		# Callback to sender
		#
		def callback
			@sender.method(@callback_method).call(@results)
		end

	end
end
