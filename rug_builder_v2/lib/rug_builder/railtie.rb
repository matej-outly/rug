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
require 'rug_builder/helpers/format_helper'
require 'rug_builder/helpers/map_helper'
require 'rug_builder/helpers/menu_helper'
require 'rug_builder/helpers/table_helper'

module RugBuilder
	class Railtie < Rails::Railtie
		
		initializer "rug_builder.helpers" do
			ActionView::Base.send :include, Helpers::FormHelper
			ActionView::Base.send :include, Helpers::FormatHelper
			ActionView::Base.send :include, Helpers::MapHelper
			ActionView::Base.send :include, Helpers::MenuHelper
			ActionView::Base.send :include, Helpers::TableHelper
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
			require "rug_builder/#{RugBuilder.frontend_framework}/form_builder"
			require "rug_builder/google/map_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/menu_builder"
			require "rug_builder/#{RugBuilder.frontend_framework}/table_builder"

		end

	end
end