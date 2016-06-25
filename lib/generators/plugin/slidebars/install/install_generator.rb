# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Slidebars library.
# *
# * Author: Matěj Outlý
# * Date  : 24. 6. 2016
# *
# *****************************************************************************

module Plugin
	module Slidebars
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/slidebars")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/slidebars")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_slidebars")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_slidebars")
			end

			def clone_git_repository
				run("git clone https://github.com/adchsm/Slidebars.git #{Dir.pwd}/vendor/assets/libraries/_slidebars")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_slidebars/dist/slidebars.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/slidebars/slidebars.js") if !filename.nil?

				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_slidebars/dist/slidebars.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/slidebars/slidebars.css") if !filename.nil?

			end

			def copy_user_js
				copy_file("slidebars.js", "#{Dir.pwd}/app/assets/javascripts/libraries/slidebars.js")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Slidebars
//= require slidebars/slidebars
//= require ./libraries/slidebars
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require slidebars/slidebars
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_slidebars")
			end

		end
	end
end