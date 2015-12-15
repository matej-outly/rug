# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of jCrop library.
# *
# * Author: Matěj Outlý
# * Date  : 17. 8. 2015
# *
# *****************************************************************************

module Plugin
	module Jcrop
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/jcrop")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/jcrop")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_jcrop")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_jcrop")
			end

			def clone_git_repository
				run("git clone https://github.com/tapmodo/Jcrop.git #{Dir.pwd}/vendor/assets/libraries/_jcrop")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_jcrop/js/jquery.Jcrop.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/jcrop/jcrop.js") if !filename.nil?
				
				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_jcrop/css/jquery.Jcrop.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/jcrop/jcrop.css") if !filename.nil?

				# Images
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_jcrop/css/Jcrop.gif") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/jcrop/Jcrop.gif")if !filename.nil?

			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// jCrop
//= require jcrop/jcrop
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require jcrop/jcrop
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_jcrop")
			end

		end
	end
end