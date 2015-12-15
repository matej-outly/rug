# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of AutoComplete library.
# *
# * Author: Matěj Outlý
# * Date  : 15. 12. 2015
# *
# *****************************************************************************

module Plugin
	module Autocomplete
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/autocomplete")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/autocomplete")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_autocomplete")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_autocomplete")
			end

			def clone_git_repository
				run("git clone https://github.com/Pixabay/jQuery-autoComplete.git #{Dir.pwd}/vendor/assets/libraries/_autocomplete")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_autocomplete/jquery.auto-complete.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/autocomplete/autocomplete.js") if !filename.nil?
				
				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_autocomplete/jquery.auto-complete.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/autocomplete/autocomplete.css") if !filename.nil?

			end

			def copy_user_css
				copy_file("autocomplete.gumby.css", "#{Dir.pwd}/vendor/assets/libraries/autocomplete/autocomplete.gumby.css")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// AutoComplete
//= require autocomplete/autocomplete
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require autocomplete/autocomplete
 *= require autocomplete/autocomplete.gumby
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_autocomplete")
			end

		end
	end
end