# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug teplater - file types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Templater

		# *********************************************************************
		# File
		# *********************************************************************

		def self.file(column)
			return OpenStruct.new({
				url: ":#{column_url}_url",
				exists?: true
			})
		end

		# *********************************************************************
		# Picture
		# *********************************************************************

		def self.picture(column)
			o = Object.new
			def o.column=(column) @column = column end
			o.column = column	
			def o.url(style = nil) (style ? ":#{@column}_url_#{style}" : ":#{@column}_url") end
			def o.exists?() true end
			return o
		end

	end
end