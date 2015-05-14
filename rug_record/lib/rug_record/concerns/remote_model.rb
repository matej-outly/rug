# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Remote model
# *
# * Author: Matěj Outlý
# * Date  : 12. 5. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module RemoteModel extend ActiveSupport::Concern

			module ClassMethods
				
				def is_remote_model(connection_prefix)
					establish_connection "#{connection_prefix.to_s}_#{Rails.env.to_s}".to_sym
				end

			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::RemoteModel)
