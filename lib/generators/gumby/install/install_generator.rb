# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of Gumby Framework and compatible jQuery and 
# * Modernizr libraries into the application.
# *
# * Author: Matěj Outlý
# * Date  : 18. 11. 2014
# *
# *****************************************************************************

module Gumby
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		
		def prepare_gem_dependencies
			append_file("#{Dir.pwd}/Gemfile") do
%{
# Gumby dependencies
gem 'modular-scale'
gem 'compass'
}
			end
			run("bundle install")
		end

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/gumby")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/gumby")
		end

		def clone_git_repository
			run("git clone https://github.com/GumbyFramework/Gumby.git #{Dir.pwd}/vendor/assets/libraries/gumby")
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/gumby/.git")
		end

		def copy_jquery_js
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/gumby/js/libs/jquery-*.min.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/jquery/jquery.min.js")
			end
		end

		def copy_modernizr_js
			filename = nil
			Dir.glob("#{Dir.pwd}/vendor/assets/libraries/gumby/js/libs/modernizr-*.min.js") do |f|
				filename = f
			end
			if !filename.nil?
				copy_file(filename, "#{Dir.pwd}/vendor/assets/libraries/modernizr/modernizr.min.js")
			end
		end			

		def replace_sass_fonts
			remove_file("#{Dir.pwd}/vendor/assets/libraries/gumby/sass/_fonts.scss")
			copy_file("_fonts.scss", "#{Dir.pwd}/vendor/assets/libraries/gumby/sass/_fonts.scss")
		end

		def compile_compass
			inside("#{Dir.pwd}/vendor/assets/libraries/gumby") do
				run("compass compile")
			end
		end
	end
end