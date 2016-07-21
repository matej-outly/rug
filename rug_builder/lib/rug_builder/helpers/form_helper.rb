# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 28. 6. 2015
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module FormHelper

			def rug_form_for(object, options = {}, &block)

				# Builder
				options[:builder] = RugBuilder::FormBuilder
				
				# Automatic URL
				if options[:create_url] || options[:update_url]
					if options[:create_url] && object.new_record?
						options[:url] = RugSupport::PathResolver.new(self).resolve(options[:create_url])
					elsif options[:update_url] && !object.new_record?
						options[:url] = RugSupport::PathResolver.new(self).resolve(options[:update_url], object)
					else
						raise "Unable to resolve form URL."
					end
				end

				# Automatic instance
				if object.is_a?(Class)
					object = object.new
				end

				form_for(object, options, &block)
			end

		end
	end
end
