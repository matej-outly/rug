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

require 'rug_builder/helpers/form_helper'
require 'rug_builder/helpers/menu_helper'
require 'rug_builder/helpers/table_helper'

module RugBuilder
	class Railtie < Rails::Railtie
		initializer "rug_builder.helpers" do
			ActionView::Base.send :include, Helpers::FormHelper
			ActionView::Base.send :include, Helpers::MenuHelper
			ActionView::Base.send :include, Helpers::TableHelper
		end
	end
end