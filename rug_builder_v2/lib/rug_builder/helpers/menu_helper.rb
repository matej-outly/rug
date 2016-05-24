# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 28. 6. 2015
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module MenuHelper

			def rug_menu_for(object, options = {}, &block)
				RugBuilder::MenuBuilder.new(self).render(object, options, &block)
			end

		end
	end
end