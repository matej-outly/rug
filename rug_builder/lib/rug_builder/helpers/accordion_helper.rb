# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 9. 8. 2017
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module AccordionHelper

			def rug_accordion(options = {}, &block)
				RugBuilder::AccordionBuilder.new(self).render(options, &block)
			end

		end
	end
end