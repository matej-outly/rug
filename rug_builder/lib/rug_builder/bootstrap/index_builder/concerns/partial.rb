# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug index builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	class IndexBuilder
		module Concerns
			module Partial extend ActiveSupport::Concern

				def clear_partial
					@partial = nil
				end

				def capture_partial(partial)
					@partial = "" if @partial.nil?
					@partial += partial
					return partial
				end

				def render_partial
					@partial.to_s.html_safe
				end

			end
		end
	end
#end
end