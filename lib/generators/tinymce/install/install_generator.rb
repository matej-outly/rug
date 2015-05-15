# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integrate latest version of TinyMCE into the application.
# *
# * Author: Matěj Outlý
# * Date  : 18. 11. 2014
# *
# *****************************************************************************

module Tinymce
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		def create_directory
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/tinymce")
			empty_directory("#{Dir.pwd}/vendor/assets/libraries/tinymce")
		end

		def clone_tinymce_git_repository
			run("git clone https://github.com/tinymce/tinymce-dist.git #{Dir.pwd}/vendor/assets/libraries/tinymce")
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/tinymce/.git")
		end

		def clone_codemirror_plugin_git_repository
			run("git clone https://github.com/PacificMorrowind/tinymce-codemirror.git #{Dir.pwd}/vendor/assets/libraries/tinymce/plugins/codemirror")
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/tinymce/plugins/codemirror/.git")
		end

		def clone_codemirror_git_repository
			run("git clone https://github.com/codemirror/CodeMirror.git #{Dir.pwd}/vendor/assets/libraries/tinymce/plugins/codemirror/codemirror-4.8")
			run("cd #{Dir.pwd}/vendor/assets/libraries/tinymce/plugins/codemirror/codemirror-4.8 && git checkout tags/4.8.0")
			remove_dir("#{Dir.pwd}/vendor/assets/libraries/tinymce/plugins/codemirror/codemirror-4.8/.git")
		end		

		def copy_tinymce_cs_translation
			copy_file("cs.js", "#{Dir.pwd}/vendor/assets/libraries/tinymce/langs/cs.js")
		end

		def copy_codemirror_plugin_cs_translation
			copy_file("codemirror/cs.js", "#{Dir.pwd}/vendor/assets/libraries/tinymce/plugins/codemirror/langs/cs.js")
		end

		def copy_user_js
			copy_file("tinymce.js", "#{Dir.pwd}/app/assets/javascripts/libraries/tinymce.js")
			copy_file("tinymce_inline.js", "#{Dir.pwd}/app/assets/javascripts/libraries/tinymce_inline.js")
		end

		def copy_user_css
			copy_file("tinymce.css", "#{Dir.pwd}/app/assets/stylesheets/libraries/tinymce.css")
			copy_file("tinymce_inline.css", "#{Dir.pwd}/app/assets/stylesheets/libraries/tinymce_inline.css")
		end

	end
end