# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Sidr library.
# *
# * Author: Matěj Outlý
# * Date  : 18. 2. 2012
# *
# *****************************************************************************

module Plugin
	module Sidr
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/sidr")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/sidr")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_sidr")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_sidr")
			end

			def clone_git_repository
				run("git clone https://github.com/artberri/sidr.git #{Dir.pwd}/vendor/assets/libraries/_sidr")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_sidr/dist/jquery.sidr.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/sidr/sidr.js") if !filename.nil?

			end

			def copy_user_js
				copy_file("sidr.js", "#{Dir.pwd}/app/assets/javascripts/libraries/sidr.js")
			end

			def copy_user_css
				copy_file("sidr.gumby.css", "#{Dir.pwd}/vendor/assets/libraries/sidr/sidr.gumby.css")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Sidr
//= require sidr/sidr
//= require ./libraries/sidr
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require sidr/sidr.gumby
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_sidr")
			end

		end
	end
end