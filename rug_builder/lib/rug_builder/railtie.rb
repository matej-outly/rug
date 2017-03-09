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

require "rug_builder/helpers/button_helper"
require "rug_builder/helpers/chart_helper"
require "rug_builder/helpers/form_helper"
require "rug_builder/helpers/format_helper"
require "rug_builder/helpers/icon_helper"
require "rug_builder/helpers/label_helper"
require "rug_builder/helpers/list_helper"
require "rug_builder/helpers/map_helper"
require "rug_builder/helpers/menu_helper"
require "rug_builder/helpers/nested_helper"
require "rug_builder/helpers/pagination_helper"
require "rug_builder/helpers/table_helper"
require "rug_builder/helpers/tabs_helper"
require "rug_builder/helpers/tree_helper"

module RugBuilder
	class Railtie < Rails::Railtie
		
		initializer "rug_builder.helpers" do
			ActionView::Base.send :include, Helpers::ButtonHelper
			ActionView::Base.send :include, Helpers::ChartHelper
			ActionView::Base.send :include, Helpers::FormHelper
			ActionView::Base.send :include, Helpers::FormatHelper
			ActionView::Base.send :include, Helpers::IconHelper
			ActionView::Base.send :include, Helpers::LabelHelper
			ActionView::Base.send :include, Helpers::ListHelper
			ActionView::Base.send :include, Helpers::MapHelper
			ActionView::Base.send :include, Helpers::MenuHelper
			ActionView::Base.send :include, Helpers::NestedHelper
			ActionView::Base.send :include, Helpers::PaginationHelper
			ActionView::Base.send :include, Helpers::TableHelper
			ActionView::Base.send :include, Helpers::TabsHelper
			ActionView::Base.send :include, Helpers::TreeHelper
		end

		config.before_initialize do
			
			# There is no hook after initializers loading and before routes 
			# loading (RugRecord must be completely initialized for routes 
			# loading). Therefore we need to use this hook before initializers
			# are loaded and force a special rug_record.rb initializer to be 
			# included in advance (we expect that this initializer defines 
			# which RugRecord submodules should be loaded).
			config_path = Rails.root.to_s + "/config/initializers/rug_builder.rb"
			if File.file?(config_path)
				require config_path
			end

			# Config dependent builders
			require "rug_builder/#{RugBuilder.frontend_framework}/button_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/chart_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/form_builder"
			require "rug_builder/#{RugBuilder.icon_framework}/icon_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/label_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/list_builder"
			require "rug_builder/#{RugBuilder.map_framework}/map_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/menu_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/table_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/tabs_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/tree_builder"
			
		end

	end
end