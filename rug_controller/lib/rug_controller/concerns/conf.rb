# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Binding of config object to controller 
# *
# * Author: Matěj Outlý
# * Date  : 20. 2. 2016
# *
# *****************************************************************************

require "action_controller"

module RugController
	module Concerns
		module Conf extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Create config object when some subclass is defined
				#
				def inherited(child_class)
					child_class.conf = RugController::ControllerConfig.new(child_class)
					super
				end

				#
				# Set config object
				#
				def conf=(conf)
					@conf = conf
				end

				#
				# Get config object (or some config option)
				#
				def conf(*args)
					result = @conf
					args.each do |key|
						if !result.nil?
							result = result[key.to_sym]
						end
					end
					return result
				end

			end

			#
			# Get config object
			#
			def conf(*args)
				return self.class.conf(*args)
			end

		end
	end
end

ActionController::Base.send(:include, RugController::Concerns::Conf)