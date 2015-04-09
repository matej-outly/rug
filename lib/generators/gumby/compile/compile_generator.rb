# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Compile SASS changes in Gumby Framework
# *
# * Author: Matěj Outlý
# * Date  : 18. 11. 2014
# *
# *****************************************************************************

module Gumby
	class CompileGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		def compile_compass
			inside("#{Dir.pwd}/vendor/assets/libraries/gumby") do
				run("compass compile")
			end
		end
	end
end
