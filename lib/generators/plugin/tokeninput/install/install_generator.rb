# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Tokeninput library.
# *
# * Author: Matěj Outlý
# * Date  : 29. 10. 2015
# *
# *****************************************************************************

module Plugin
	module Tokeninput
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def create_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/tokeninput")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/tokeninput")
			end

			def create_tmp_directory
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_tokeninput")
				empty_directory("#{Dir.pwd}/vendor/assets/libraries/_tokeninput")
			end

			def clone_git_repository
				run("git clone https://github.com/loopj/jquery-tokeninput.git #{Dir.pwd}/vendor/assets/libraries/_tokeninput")
			end

			def copy_files
				
				# JS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_tokeninput/src/jquery.tokeninput.js") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/tokeninput/tokeninput.js") if !filename.nil?

				# CSS
				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_tokeninput/styles/token-input.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/tokeninput/tokeninput.css") if !filename.nil?

				filename = nil
				Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_tokeninput/styles/token-input-facebook.css") { |f| filename = f }
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/tokeninput/tokeninput.facebook.css") if !filename.nil?

				#filename = nil
				#Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_tokeninput/styles/token-input-mac.css") { |f| filename = f }
				#copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/tokeninput/tokeninput.mac.css") if !filename.nil?

			end
			
			def copy_user_css
				copy_file("tokeninput.gumby.css", "#{Dir.pwd}/vendor/assets/libraries/tokeninput/tokeninput.gumby.css")
			end

			def integrate_js
				append_file("#{Dir.pwd}/app/assets/javascripts/application.js") do
%{
// Tokeninput
//= require tokeninput/tokeninput
}
				end
			end

			def integrate_css
				append_file("#{Dir.pwd}/app/assets/stylesheets/application.css") do
%{
/*
 *= require tokeninput/tokeninput
 *= require tokeninput/tokeninput.facebook
 *= require tokeninput/tokeninput.gumby
 */
}
				end
			end

			def cleanup
				remove_dir("#{Dir.pwd}/vendor/assets/libraries/_tokeninput")
			end

		end
	end
end