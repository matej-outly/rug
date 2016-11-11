# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

# Parts
require "rug_builder/bootstrap/table_builder/util"
require "rug_builder/bootstrap/table_builder/links"
require "rug_builder/bootstrap/table_builder/show"
require "rug_builder/bootstrap/table_builder/index"

module RugBuilder
#	module Bootstrap
		class TableBuilder
			
			#
			# Constructor
			#
			def initialize(template)
				@template = template
				@path_resolver = RugSupport::PathResolver.new(@template)
				@icon_builder = RugBuilder::IconBuilder
			end

		end
#	end
end
