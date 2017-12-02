# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Session management
# *
# * Author: Matěj Outlý
# * Date  : 8. 2. 2017
# *
# *****************************************************************************

require "action_controller"

module RugController
	module Concerns
		module SessionParams extend ActiveSupport::Concern

			def session_key
				return controller_name
			end

			def save_params_to_session(params)
				session[session_key] = {} if session[session_key].nil?
				session[session_key]["params"] = params if !params.nil?
			end

			def load_params_from_session
				if !session[session_key].nil? && !session[session_key]["params"].nil?
					return session[session_key]["params"].symbolize_keys
				else
					return {}
				end
			end

		end
	end
end

ActionController::Base.send(:include, RugController::Concerns::SessionParams)
