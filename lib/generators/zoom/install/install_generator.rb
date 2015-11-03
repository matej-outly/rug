# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of jQuery Zoom library.
# *
# * Author: Matěj Outlý
# * Date  : 1. 11. 2015
# *
# *****************************************************************************

module Zoom
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/zoom")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/zoom")
		end

		def create_tmp_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_zoom")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/_zoom")
		end

		def clone_git_repository
			run("git clone https://github.com/jackmoore/zoom.git #{Dir.pwd}/vendor/assets/libraries/_zoom")
		end

		def copy_files
			
			# JS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_zoom/jquery.zoom.js") { |f| filename = f }
			copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/zoom/jquery.zoom.js") if !filename.nil?

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_zoom")
		end

	end
end