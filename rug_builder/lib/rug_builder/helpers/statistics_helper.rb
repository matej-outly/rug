# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 20. 4. 2017
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module StatisticsHelper

			def rug_statistics(options = {}, &block)
				RugBuilder::StatisticsBuilder.new(self).render(options, &block)
			end

		end
	end
end