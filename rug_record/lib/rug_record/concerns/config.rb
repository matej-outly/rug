# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Config
# *
# * Author: Matěj Outlý
# * Date  : 8. 1. 2015
# *
# *****************************************************************************

require "active_record"
require "rug_record/config"

module RugRecord
	module Concerns
		module Config extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Create config object when some subclass is defined
				#
				def inherited(child_class)
					child_class.config = RugRecord::Config.new(child_class)
					super
				end

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

			end

			#
			# Get config object
			#
			def config(*args)
				return self.class.config(*args)
			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Config)