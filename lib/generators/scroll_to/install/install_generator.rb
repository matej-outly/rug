# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of ScrollTo library.
# *
# * Author: Matěj Outlý
# * Date  : 19. 8. 2015
# *
# *****************************************************************************

module ScrollTo
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/scroll_to")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/scroll_to")
		end

		def create_tmp_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_scroll_to")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/_scroll_to")
		end

		def clone_git_repository
			run("git clone https://github.com/flesler/jquery.scrollTo.git #{Dir.pwd}/vendor/assets/libraries/_scroll_to")
		end

		def copy_files
			
			# JS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_scroll_to/jquery.scrollTo.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/scroll_to/jquery.scrollto.js")
			end

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_scroll_to")
		end

	end
end