# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 4. 8. 2017
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module ModalHelper

			def rug_modal(id, options = {}, &block)
				RugBuilder::ModalBuilder.new(self).render(id, options, &block)
			end

		end
	end
end