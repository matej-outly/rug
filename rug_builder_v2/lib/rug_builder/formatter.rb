# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

# Parts
require "rug_builder/formatter/address"
require "rug_builder/formatter/array"
require "rug_builder/formatter/basic"
require "rug_builder/formatter/datetime"
require "rug_builder/formatter/enum"
require "rug_builder/formatter/file"
require "rug_builder/formatter/geo"
require "rug_builder/formatter/name"
require "rug_builder/formatter/range"
require "rug_builder/formatter/relation"

module RugBuilder
	class Formatter

		def self.initialize(template)
			@template = template
		end

	end
end