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

			def rug_list_for(data_path, options = {}, &block)
				RugBuilder::ListBuilder.new(self).list(data_path, options, &block)
			end

		end
	end
end