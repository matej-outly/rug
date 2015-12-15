# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Fancybox library.
# *
# * Author: Matěj Outlý
# * Date  : 11. 6. 2015
# *
# *****************************************************************************

module Plugin
	module Fancybox
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/fancybox")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/fancybox")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_fancybox")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_fancybox")
			end

			def clone_git_repository
				run("git clone https://github.com/fancyapps/fancyBox.git #{Dir.pwd}/vendor/assets/libraries/_fancybox")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_fancybox/source/jquery.fancybox.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/fancybox/fancybox.js") if !filename.nil?

				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_fancybox/source/jquery.fancybox.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/fancybox/fancybox.css") if !filename.nil?		

				# GIF images
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_fancybox/source/*.gif") do |filename| 
					copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/fancybox/#{File.basename(filename)}")
				end

				# PNG images
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_fancybox/source/*.png") do |filename| 
					copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/fancybox/#{File.basename(filename)}")
				end

			end

			def copy_user_js
				copy_file("fancybox.js", "#{Dir.pwd}/app/assets/javascripts/libraries/fancybox.js")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Fancybox
//= require fancybox/fancybox
//= require libraries/fancybox
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require fancybox/fancybox
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_fancybox")
			end

		end
	end
end