# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Chart.js library.
# *
# * Author: Matěj Outlý
# * Date  : 1. 11. 2015
# *
# *****************************************************************************

module Chart
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/chart")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/chart")
		end

		def create_tmp_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_chart")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/_chart")
		end

		def clone_git_repository
			run("git clone https://github.com/nnnick/Chart.js.git #{Dir.pwd}/vendor/assets/libraries/_chart")
		end

		def copy_files
			
			# JS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_chart/Chart.js") { |f| filename = f }
			copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/chart/chart.js") if !filename.nil?

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_chart")
		end

	end
end