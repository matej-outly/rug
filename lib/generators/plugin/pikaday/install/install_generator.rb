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

module Plugin
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
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_pikaday/pikaday.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/pikaday/pikaday.js") if !filename.nil?
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_pikaday/plugins/pikaday.jquery.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/pikaday/pikaday.jquery.js") if !filename.nil?
				
				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_pikaday/css/pikaday.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/pikaday/pikaday.css") if !filename.nil?

			end

			def copy_user_css
				copy_file("pikaday.gumby.css", "#{Dir.pwd}/vendor/assets/libraries/pikaday/pikaday.gumby.css")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Moment
//= require moment

// Pikaday
//= require pikaday/pikaday
//= require pikaday/pikaday.jquery
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require pikaday/pikaday
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_pikaday")
			end

		end
	end
end