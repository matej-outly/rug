# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug templater
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

# Parts
require "rug_builder/templater/file"

module RugBuilder
	class Templater

		def self.method_missing(method_name, *arguments)
			":#{arguments.first}"
		end

	end
end