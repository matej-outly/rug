# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	module Concerns
		module Brs extend ActiveSupport::Concern

			def br(options = {})
				self.add_br(options) if self.respond_to?(:add_br, true) 
				return ""
			end

		end
	end
#end
end
