# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 24. 11. 2015
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module MapHelper

			def rug_map(name, options = {}, &block)
				RugBuilder::MapBuilder.new(self).render(name, options, &block)
			end

		end
	end
end