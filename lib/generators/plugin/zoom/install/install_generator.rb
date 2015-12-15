# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of jQuery Zoom library.
# *
# * Author: Matěj Outlý
# * Date  : 1. 11. 2015
# *
# *****************************************************************************

module Plugin
	module Zoom
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/zoom")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/zoom")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_zoom")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_zoom")
			end

			def clone_git_repository
				run("git clone https://github.com/jackmoore/zoom.git #{Dir.pwd}/vendor/assets/libraries/_zoom")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_zoom/jquery.zoom.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/zoom/zoom.js") if !filename.nil?

			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Zoom
//= require zoom/zoom
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_zoom")
			end

		end
	end
end