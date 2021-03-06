# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 18. 7. 2016
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module ButtonHelper

			def rug_button(label, url = nil, options = {})
				RugBuilder::ButtonBuilder.new(self).button(label, url, options)
			end

			def rug_dropdown_button(label = nil, options = {}, &block)
				RugBuilder::ButtonBuilder.new(self).dropdown_button(label, options, &block)
			end

			def rug_button_group(options = {}, &block)
				RugBuilder::ButtonBuilder.new(self).button_group(options, &block)
			end

		end
	end
end