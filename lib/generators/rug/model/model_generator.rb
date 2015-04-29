# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Create common model.
# *
# * Author: Matěj Outlý
# * Date  : 29. 4. 2015
# *
# *****************************************************************************

module Rug
	class ModelGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		# 
		# Define arguments and options
		#
		argument :model_path
		argument :columns, :optional => :true, :type => :array

		def create_model
			template("model.rb", "app/models/#{model_path.to_snake.singularize}.rb")
		end

		def create_migration
			template("migration.rb", "db/migrate/#{Time.now.strftime('%Y%m%d%H%M%S')}_create_#{model_name.pluralize}.rb")
		end

	private

		def model_name
			model_path.to_snake.split("/").last
		end

	end
end