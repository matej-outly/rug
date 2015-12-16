# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Flot library.
# *
# * Author: Matěj Outlý
# * Date  : 1. 11. 2015
# *
# *****************************************************************************

module Plugin
	module Flot
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/flot")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/flot")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_flot")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_flot")
			end

			def clone_git_repository
				run("git clone https://github.com/flot/flot.git #{Dir.pwd}/vendor/assets/libraries/_flot")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_flot/jquery.flot.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/flot/flot.js") if !filename.nil?

			end
			
			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Flot
//= require flot/flot
}
				end
			end
			
			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_flot")
			end

		end
	end
end