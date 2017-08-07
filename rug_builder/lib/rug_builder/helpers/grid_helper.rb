# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 6. 8. 2017
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module GridHelper

			def rug_grid(options = {}, &block)
				RugBuilder::GridBuilder.new(self).render(options, &block)
			end

		end
	end
end