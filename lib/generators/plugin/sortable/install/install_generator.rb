# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of jQuery Sortable library.
# *
# * Author: Matěj Outlý
# * Date  : 1. 11. 2015
# *
# *****************************************************************************

module Plugin
	module Sortable
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/sortable")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/sortable")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_sortable")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_sortable")
			end

			def clone_git_repository
				run("git clone https://github.com/johnny/jquery-sortable.git #{Dir.pwd}/vendor/assets/libraries/_sortable")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_sortable/source/js/jquery-sortable.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/sortable/sortable.js") if !filename.nil?

			end
			
			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Sortable
//= require sortable/sortable
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_sortable")
			end

		end
	end
end