# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 29. 6. 2015
# *
# *****************************************************************************

module RugController
	module Helpers
		module RenderHelper

			def render_component(component)
				if component
					return render(partial: component.to_partial_path, object: component)
				else
					return ""
				end
			end

		end
	end
end
