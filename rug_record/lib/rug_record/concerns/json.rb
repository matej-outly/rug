# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * JSON
# *
# * Author: Matěj Outlý
# * Date  : 12. 11. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Json extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Set JSON additional methods
				#
				def add_methods_to_json(methods)
					if !methods.is_a? Array
						methods = [methods]
					end
					if @json_additional_methods.nil?
						@json_additional_methods = []
					end
					@json_additional_methods.concat(methods)
				end

				#
				# Get JSON additional methods
				#
				def json_additional_methods
					if @json_additional_methods.nil?
						@json_additional_methods = []
					end
					return @json_additional_methods
				end

			end

			#
			# Export model to JSON
			#
			def as_json(options = {})
				if options[:methods].nil?
					options[:methods] = self.class.json_additional_methods
				elsif options[:methods].is_a? Array
					options[:methods].concat(self.class.json_additional_methods)
				else
					options[:methods] = [options[:methods]].concat(self.class.json_additional_methods)
				end
				super(options)
			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Json)