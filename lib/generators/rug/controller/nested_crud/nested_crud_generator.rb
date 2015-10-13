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

			def form_field(column_name, column_type)
				return case column_type
					when "string" then "text_input_row :#{column_name}, :text_field"
					when "text" then "text_area_row :#{column_name}"
					when "integer" then "text_input_row :#{column_name}, :number_field"
					when "date" then "datepicker_row :#{column_name}"
					when "time" then "text_input_row :#{column_name}, :time_field"
					when "datetime" then "text_input_row :#{column_name}, :datetime_local_field"
					when "boolean" then "checkbox_row :#{column_name}"
					when "file" then "dropzone_row :#{column_name}"
					when "picture" then "dropzone_row :#{column_name}" 
					when "enum" then "picker_row :#{column_name}" 
					when "belongs_to" then "picker_row :#{column_name}"
					when "address" then "address_row :#{column_name}"
					when "currency" then "text_input_row :#{column_name}, :number_field"
					else "text_input_row :#{column_name}, :text_field"
				end
			end

		end
	end
end