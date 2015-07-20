# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Railtie for view helpers integration
# *
# * Author: Matěj Outlý
# * Date  : 2. 7. 2015
# *
# *****************************************************************************

require 'rug_view/helpers/nested_helper'
require 'rug_view/helpers/pagination_helper'

module RugView
	class Railtie < Rails::Railtie
		initializer "rug_view.helpers" do
			ActionView::Base.send :include, Helpers::NestedHelper
			ActionView::Base.send :include, Helpers::PaginationHelper
		end
	end
end