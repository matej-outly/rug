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

		def create_tmp_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_pikaday")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/_pikaday")
		end

		def clone_git_repository
			run("git clone https://github.com/dbushell/Pikaday.git #{Dir.pwd}/vendor/assets/libraries/_pikaday")
		end

		def copy_files
			
			# JS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_pikaday/pikaday.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/pikaday/pikaday.js")
			end

			# JS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_pikaday/plugins/pikaday.jquery.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/pikaday/pikaday.jquery.js")
			end

			# CSS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_pikaday/css/pikaday.css") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/pikaday/pikaday.css")
			end

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_pikaday")
		end

	end
end