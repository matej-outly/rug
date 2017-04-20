# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2017
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module ListHelper

			def rug_list_for(objects, options = {}, &block)
				RugBuilder::ListBuilder.new(self).list(objects, options, &block)
			end

		end
	end
end