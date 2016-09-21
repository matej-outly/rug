# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 19. 9. 2016
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module ChartHelper

			def rug_time_flexible_line_chart(path, options = {})
				RugBuilder::ChartBuilder.new(self).time_flexible_line_chart(path, options)
			end

			def rug_time_flexible_area_chart(path, options = {})
				RugBuilder::ChartBuilder.new(self).time_flexible_area_chart(path, options)
			end

		end
	end
end