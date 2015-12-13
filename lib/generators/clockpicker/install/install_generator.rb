# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of ClockPicker library.
# *
# * Author: Matěj Outlý
# * Date  : 13. 12. 2015
# *
# *****************************************************************************

module Clockpicker
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/clockpicker")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/clockpicker")
		end

		def create_tmp_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_clockpicker")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/_clockpicker")
		end

		def clone_git_repository
			run("git clone https://github.com/weareoutman/clockpicker.git #{Dir.pwd}/vendor/assets/libraries/_clockpicker")
		end

		def copy_files
			
			# JS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_clockpicker/dist/jquery-clockpicker.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/clockpicker/jquery-clockpicker.js")
			end

			# CSS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_clockpicker/dist/jquery-clockpicker.css") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/clockpicker/jquery-clockpicker.css")
			end

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_clockpicker")
		end

	end
end