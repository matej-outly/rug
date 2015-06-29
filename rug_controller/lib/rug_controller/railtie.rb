# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Railtie for view helpers integration
# *
# * Author: Matěj Outlý
# * Date  : 28. 6. 2015
# *
# *****************************************************************************

require 'rug_controller/helpers/render_helper'

module RugController
	class Railtie < Rails::Railtie
		initializer "rug_controller.helpers" do
			ActionView::Base.send :include, Helpers::RenderHelper
		end
	end
end