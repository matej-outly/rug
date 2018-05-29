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
		module IconHelper

			def rug_icon(icon, options = {})
				RugBuilder::IconBuilder.new(self).render(icon, options)
			end

		end
	end
end