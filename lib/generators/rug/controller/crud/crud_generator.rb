# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Create common CRUD controller.
# *
# * Author: Matěj Outlý
# * Date  : 29. 4. 2015
# *
# *****************************************************************************

module Rug
	module Controller
		class CrudGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			# 
			# Define arguments and options
			#
			argument :controller_path
			argument :model_path
			argument :columns, :optional => :true, :type => :array

			def create_controller
				template("controller.rb", "app/controllers/#{controller_path.to_snake}_controller.rb")
			end

			def create_action_views
				template("index.html.erb", "app/views/#{controller_path.to_snake}/index.html.erb")
				template("show.html.erb", "app/views/#{controller_path.to_snake}/show.html.erb")
				template("new.html.erb", "app/views/#{controller_path.to_snake}/new.html.erb")
				template("edit.html.erb", "app/views/#{controller_path.to_snake}/edit.html.erb")
			end

			def create_partial_views
				template("_form.html.erb", "app/views/#{controller_path.to_snake}/_form.html.erb")
				template("_actions.html.erb", "app/views/#{controller_path.to_snake}/_actions.html.erb")
				template("_related.html.erb", "app/views/#{controller_path.to_snake}/_related.html.erb")
				template("_filters.html.erb", "app/views/#{controller_path.to_snake}/_filters.html.erb")
			end

		private

			def controller_name
				controller_path.to_snake.split("/").last
			end

			def model_name
				model_path.to_snake.split("/").last
			end

		end
	end
end