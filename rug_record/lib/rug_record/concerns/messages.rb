# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Messages
# *
# * Author: Matěj Outlý
# * Date  : 12. 11. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Messages extend ActiveSupport::Concern

			module ClassMethods
				
				def human_notice_message(action)
					I18n.t("activerecord.notices.models.#{self.model_name.i18n_key}.#{action}")
				end

				def human_error_message(action)
					I18n.t("activerecord.errors.models.#{self.model_name.i18n_key}.#{action}")
				end

			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Messages)