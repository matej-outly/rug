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
				
				def human_notice_message(action, params = {})
					I18n.t("#{ self < ActiveRecord::Base ? "activerecord" : "activemodel"}.notices.models.#{self.model_name.i18n_key}.#{action}", params)
				end

				def human_error_message(action, params = {})
					I18n.t("#{ self < ActiveRecord::Base ? "activerecord" : "activemodel"}.errors.models.#{self.model_name.i18n_key}.#{action}", params)
				end

				def human_error_attribute_message(attribute, condition, params = {})
					I18n.t("#{ self < ActiveRecord::Base ? "activerecord" : "activemodel"}.errors.models.#{self.model_name.i18n_key}.attributes.#{attribute}.#{condition}", params)
				end

				def human_attribute_name(attribute, params = {})

					I18n.t("#{ self < ActiveRecord::Base ? "activerecord" : "activemodel"}.attributes.#{self.model_name.i18n_key}.#{attribute}", params)
				end

				def human_attribute_unit(attribute, params = {})
					I18n.t("#{ self < ActiveRecord::Base ? "activerecord" : "activemodel"}.attributes.#{self.model_name.i18n_key}.#{attribute}_unit", params)
				end
				
			end

		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Messages)