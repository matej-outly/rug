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
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_cycle2/build/*.min.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/cycle2/jquery.cycle2.min.js")
			end

			# Map
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_cycle2/build/*.js.map") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/cycle2/jquery.cycle2.js.map")
			end

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_cycle2")
		end

	end
end