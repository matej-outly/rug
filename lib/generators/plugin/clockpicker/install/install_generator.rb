# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of ClockPicker library.
# *
# * Author: Matěj Outlý
# * Date  : 13. 12. 2015
# *
# *****************************************************************************

module Plugin
	module Clockpicker
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/clockpicker")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/clockpicker")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_clockpicker")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_clockpicker")
			end

			def clone_git_repository
				run("git clone https://github.com/weareoutman/clockpicker.git #{Dir.pwd}/vendor/assets/libraries/_clockpicker")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_clockpicker/dist/jquery-clockpicker.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/clockpicker/clockpicker.js") if !filename.nil?

				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_clockpicker/dist/jquery-clockpicker.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/clockpicker/clockpicker.css") if !filename.nil?

			end

			def copy_user_css
				copy_file("clockpicker.gumby.css", "#{Dir.pwd}/vendor/assets/libraries/clockpicker/clockpicker.gumby.css")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// ClockPicker
//= require clockpicker/clockpicker
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require clockpicker/clockpicker
 *= require clockpicker/clockpicker.gumby
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_clockpicker")
			end

		end
	end
end