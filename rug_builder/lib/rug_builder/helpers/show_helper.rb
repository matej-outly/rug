# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 19. 5. 2017
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module ShowHelper

			def rug_show(object, options = {}, &block)
				RugBuilder::ShowBuilder.new(self).render(object, options, &block)
			end

		end
	end
end