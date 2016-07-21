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

			def rug_button(label, url, options = {})
				RugBuilder::ButtonBuilder.render(label, url, options)
			end

		end
	end
end