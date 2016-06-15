# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Dropzone.js library.
# *
# * Author: Matěj Outlý
# * Date  : 11. 6. 2015
# *
# *****************************************************************************

module Plugin
	module Dropzone
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/dropzone")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/dropzone")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_dropzone")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_dropzone")
			end

			def clone_git_repository
				run("git clone https://github.com/enyo/dropzone.git #{Dir.pwd}/vendor/assets/libraries/_dropzone")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_dropzone/dist/dropzone.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/dropzone/dropzone.js") if !filename.nil?
				
				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_dropzone/dist/dropzone.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/dropzone/dropzone.css") if !filename.nil?
				
			end

			def copy_user_css
				copy_file("dropzone.bootstrap.css", "#{Dir.pwd}/vendor/assets/libraries/dropzone/dropzone.bootstrap.css")
				copy_file("dropzone.gumby.css", "#{Dir.pwd}/vendor/assets/libraries/dropzone/dropzone.gumby.css")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Dropzone
//= require dropzone/dropzone
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require dropzone/dropzone
 *= require dropzone/dropzone.bootstrap
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_dropzone")
			end

		end
	end
end