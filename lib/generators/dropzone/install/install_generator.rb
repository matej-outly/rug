# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Dropzone.js library.
# *
# * Author: Matěj Outlý
# * Date  : 11. 6. 2015
# *
# *****************************************************************************

module Dropzone
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/dropzone")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/dropzone")
		end

		def create_tmp_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_dropzone")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/_dropzone")
		end

		def clone_git_repository
			run("git clone https://github.com/enyo/dropzone.git #{Dir.pwd}/vendor/assets/libraries/_dropzone")
		end

		def copy_files
			
			# JS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_dropzone/dist/dropzone.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/dropzone/dropzone.js")
			end

			# CSS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_dropzone/dist/dropzone.css") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/dropzone/dropzone.css")
			end

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_dropzone")
		end

	end
end