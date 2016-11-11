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
		module TreeHelper

			def rug_tree_for(data_path, options = {})
				RugBuilder::TreeBuilder.new(self).tree(data_path, options)
			end

		end
	end
end