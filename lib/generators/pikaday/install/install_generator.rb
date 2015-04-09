# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Pikaday library.
# *
# * Author: Matěj Outlý
# * Date  : 9. 4. 2015
# *
# *****************************************************************************

module Pikaday
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		
		def prepare_gem_dependencies
			append_file("#{Dir.pwd}/Gemfile") do
%{
# Pikaday dependencies
gem 'momentjs-rails'
}
			end
			run("bundle install")
		end

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/pikaday")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/pikaday")
		end

		def clone_git_repository
			run("git clone https://github.com/dbushell/Pikaday.git #{Dir.pwd}/vendor/assets/libraries/pikaday")
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/pikaday/.git")
		end

	end
end