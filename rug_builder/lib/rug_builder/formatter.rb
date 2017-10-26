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
require "rug_builder/formatter/datetime"
require "rug_builder/formatter/enum"
require "rug_builder/formatter/file"
require "rug_builder/formatter/geo"
require "rug_builder/formatter/name"
require "rug_builder/formatter/number"
require "rug_builder/formatter/range"
require "rug_builder/formatter/relation"
require "rug_builder/formatter/text"

module RugBuilder
	class Formatter

		#
		# Get all available types
		#
		def self.types
			[
				:address, 
				
				:string_array, 
				:integer_array,
				:enum_array,
				
				:date, 
				:time, 
				:datetime, 
				:duration, 
				
				:enum, 
				:boolean, 
				:state, 
				
				:file, 
				:picture, 
				
				:geolocation, 
				:georectangle, 
				:geopolygon, 

				:name, 

				:integer, 
				:float,
				:double,
				:currency, 
				:rating, 
				
				:range, 
				:string_range,
				:integer_range, 
				:float_range, 
				:double_range,
				:currency_range,
				:date_range, 

				:belongs_to, 
				:has_many,

				:string, 
				:text, 
				:url, 
			]
		end

		#
		# Initialize subsystem with template
		#
		def self.initialize(template)
			@template = template
		end

	end
end