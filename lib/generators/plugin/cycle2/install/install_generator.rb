# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Cycle2 library.
# *
# * Author: Matěj Outlý
# * Date  : 11. 6. 2015
# *
# *****************************************************************************

module Plugin
	module Cycle2
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/cycle2")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/cycle2")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_cycle2")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_cycle2")
			end

			def clone_git_repository
				run("git clone https://github.com/malsup/cycle2.git #{Dir.pwd}/vendor/assets/libraries/_cycle2")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_cycle2/build/jquery.cycle2.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/cycle2/cycle2.js") if !filename.nil?

			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Cycle 2
//= require cycle2/cycle2
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_cycle2")
			end

		end
	end
end