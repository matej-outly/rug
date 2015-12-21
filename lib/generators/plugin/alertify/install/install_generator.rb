# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Alertify.js library.
# *
# * Author: Matěj Outlý
# * Date  : 15. 12. 2015
# *
# *****************************************************************************

module Plugin
	module Alertify
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/alertify")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/alertify")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_alertify")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_alertify")
			end

			def clone_git_repository
				run("git clone -b 0.3 --single-branch https://github.com/fabien-d/alertify.js.git #{Dir.pwd}/vendor/assets/libraries/_alertify")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_alertify/lib/alertify.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/alertify/alertify.js") if !filename.nil?
				
				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_alertify/themes/alertify.core.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/alertify/alertify.core.css") if !filename.nil?

				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_alertify/themes/alertify.default.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/alertify/alertify.default.css") if !filename.nil?

			end

			def copy_user_css
				copy_file("alertify.gumby.css", "#{Dir.pwd}/vendor/assets/libraries/alertify/alertify.gumby.css")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Alertify
//= require alertify/alertify
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require alertify/alertify.core
 *= require alertify/alertify.default
 *= require alertify/alertify.gumby
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_alertify")
			end

		end
	end
end