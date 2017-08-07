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

		#
		# Get all available types
		#
		def self.types
			[
				:address, 
				
				:string_array, 
				:integer_array,
				:enum_array,

				:string, 
				:text, 
				:integer, 
				:float,
				:double,
				:currency, 
				:url, 
				
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

				:range, 
				:string_range,
				:integer_range, 
				:float_range, 
				:double_range,
				:currency_range,
				:date_range, 

				:belongs_to, 
				:has_many
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