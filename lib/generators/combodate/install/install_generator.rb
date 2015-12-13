# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Combodate library.
# *
# * Author: Matěj Outlý
# * Date  : 13. 12. 2015
# *
# *****************************************************************************

module Combodate
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		
		def prepare_gem_dependencies
			append_file("#{Dir.pwd}/Gemfile") do
%{
# Combodate dependencies
gem 'momentjs-rails'
}
			end
			run("bundle install")
		end

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/combodate")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/combodate")
		end

		def create_tmp_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_combodate")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/_combodate")
		end

		def clone_git_repository
			run("git clone https://github.com/vitalets/combodate.git #{Dir.pwd}/vendor/assets/libraries/_combodate")
		end

		def copy_files
			
			# JS
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/_combodate/src/combodate.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/combodate/combodate.js")
			end

		end

		def cleanup
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/_combodate")
		end

	end
end