# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Referrer management
# *
# * Author: Matěj Outlý
# * Date  : 20. 2. 2016
# *
# *****************************************************************************

require "action_controller"

module RugController
	module Concerns
		module SessionReferrer extend ActiveSupport::Concern

			def save_referrer
				session["referrer"] = request.referrer
			end

			def load_referrer
				result = session["referrer"]
				session.delete("referrer")
				return result
			end

			def get_referrer
				result = session["referrer"]
				return result
			end

			def clear_referrer
				session.delete("referrer")
				return true
			end

		end
	end
end

ActionController::Base.send(:include, RugController::Concerns::SessionReferrer)
