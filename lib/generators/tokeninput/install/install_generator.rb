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
			copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/tokeninput/jquery.tokeninput.js") if !filename.nil?

			# CSS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_tokeninput/styles/token-input.css") { |f| filename = f }
			copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/tokeninput/token-input.css") if !filename.nil?

			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_tokeninput/styles/token-input-facebook.css") { |f| filename = f }
			copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/tokeninput/token-input-facebook.css") if !filename.nil?

			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_tokeninput/styles/token-input-mac.css") { |f| filename = f }
			copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/tokeninput/token-input-mac.css") if !filename.nil?

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_tokeninput")
		end

	end
end