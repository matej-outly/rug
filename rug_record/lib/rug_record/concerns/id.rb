# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Id
# *
# * Author: Matěj Outlý
# * Date  : 22. 6. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Id extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Select only given ID
				#
				def id(id)
					if id.blank?
						where("1 = 1")
					else
						where(id: id)
					end
				end

			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Id)
