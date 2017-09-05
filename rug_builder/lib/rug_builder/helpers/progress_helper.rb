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
		module ProgressHelper

			def rug_progress(progress, options = {})
				RugBuilder::ProgressBuilder.render(progress, options)
			end

		end
	end
end