# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Fancybox library.
# *
# * Author: Matěj Outlý
# * Date  : 11. 6. 2015
# *
# *****************************************************************************

module Fancybox
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/fancybox")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/fancybox")
		end

		def create_tmp_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_fancybox")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/_fancybox")
		end

		def clone_git_repository
			run("git clone https://github.com/fancyapps/fancyBox.git #{Dir.pwd}/vendor/assets/libraries/_fancybox")
		end

		def copy_files
			directory("#{Dir.pwd}/vendor/assets/libraries/_fancybox/source", "#{Dir.pwd}/vendor/assets/libraries/fancybox")
		end

		def copy_user_js
			copy_file("fancybox.js", "#{Dir.pwd}/app/assets/javascripts/libraries/fancybox.js")
		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_fancybox")
		end

	end
end