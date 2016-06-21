# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 20. 6. 2016
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module TabsHelper

			def rug_tabs
				RugBuilder::TabsBuilder.new(self)
			end

		end
	end
end