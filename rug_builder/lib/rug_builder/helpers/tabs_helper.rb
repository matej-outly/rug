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

			def rug_tabs(options = {}, &block)
				RugBuilder::TabsBuilder.new(self).render(options, &block)
			end

			def rug_tabs_header(tabs = [], options = {})
				RugBuilder::TabsBuilder.render_header(tabs, options)
			end

		end
	end
end