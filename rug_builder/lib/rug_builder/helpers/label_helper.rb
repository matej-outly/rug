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
		module LabelHelper

			def rug_label(label, options = {})
				RugBuilder::LabelBuilder.render(label, options)
			end

		end
	end
end