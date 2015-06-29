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
		module FormHelper

			def rug_form_for(object, options = {}, &block)
				options[:builder] = RugBuilder::FormBuilder
				form_for(object, options, &block)
			end

		end
	end
end
