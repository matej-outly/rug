# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Create nested CRUD controller.
# *
# * Author: Matěj Outlý
# * Date  : 12. 10. 2015
# *
# *****************************************************************************

module Rug
	module Controller
		class NestedCrudGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			# 
			# Define arguments and options
			#
			argument :controller_path
			argument :model_1_path
			argument :model_2_path
			argument :columns, :optional => :true, :type => :array

			def create_controller
				template("controller.rb", "app/controllers/#{controller_path.to_snake}_controller.rb")
			end

			def create_action_views
				template("show.html.erb", "app/views/#{controller_path.to_snake}/show.html.erb")
				template("new.html.erb", "app/views/#{controller_path.to_snake}/new.html.erb")
				template("edit.html.erb", "app/views/#{controller_path.to_snake}/edit.html.erb")
			end

			def create_partial_views
				template("_form.html.erb", "app/views/#{controller_path.to_snake}/_form.html.erb")
				template("_actions.html.erb", "app/views/#{controller_path.to_snake}/_actions.html.erb")
				template("_related.html.erb", "app/views/#{controller_path.to_snake}/_related.html.erb")
			end

		private

			def controller_name
				controller_path.to_snake.split("/").last
			end

			def model_1_name
				model_1_path.to_snake.split("/").last
			end

			def model_2_name
				model_2_path.to_snake.split("/").last
			end

			def model_2_controller_path
				arr = controller_path.to_snake.split("/")
				arr.pop
				arr << model_2_name.pluralize
				return arr.join("/")
			end

		end
	end
end