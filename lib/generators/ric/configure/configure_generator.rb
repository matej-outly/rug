# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Configure Rails application to RIC.
# *
# * Author: Matěj Outlý
# * Date  : 21. 4. 2016
# *
# *****************************************************************************

module Ric
	class ConfigureGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		# 
		# Define arguments and options
		#
		argument :app_name
		
		#
		# Update Gemfile
		#
		def update_gemfile
			
			# Indent
			gsub_file('Gemfile', /^  /, "\t")

			# Remove Turbolinks
			gsub_file('Gemfile', /^# Turbolinks.*\n/, '')
			gsub_file('Gemfile', /^gem 'turbolinks'\n/, '')

			# Add Thin
			inject_into_file 'Gemfile', :after => "group :development do" do
				"\n\t# Development server\n\tgem 'thin'\n"
			end

			# Add Quiet assets
			inject_into_file 'Gemfile', :after => "group :development do" do
				"\n\t# Assets not visible in development log\n\tgem 'quiet_assets'\n"
			end

			# Add Capistrano
			inject_into_file 'Gemfile', :after => "group :development do" do
				"\n\t# Capistrano\n\tgem 'capistrano-rails'\n\tgem 'capistrano-passenger'\n"
			end

		end

	private

		def model_name
			app_name.to_snake.split("/").last
		end

	end
end