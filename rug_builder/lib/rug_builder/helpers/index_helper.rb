# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module IndexHelper

			def rug_index(options = {}, &block)
				RugBuilder::IndexBuilder.new(self).render(options, &block)
			end

		end
	end
end