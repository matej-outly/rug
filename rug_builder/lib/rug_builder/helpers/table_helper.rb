# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 28. 6. 2015
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module TableHelper

			def rug_columns
				RugBuilder::Columns.new
			end

			def rug_show_table_for(object, columns, options = {})
				RugBuilder::TableBuilder.new(self).show(object, columns, options)
			end

			def rug_index_table_for(objects, columns, options = {})
				RugBuilder::TableBuilder.new(self).index(objects, columns, options)
			end

			def rug_hierarchical_index_table_for(objects, columns, options = {})
				RugBuilder::TableBuilder.new(self).hierarchical_index(objects, columns, options)
			end

			def rug_picture_index_table_for(objects, columns, options = {})
				RugBuilder::TableBuilder.new(self).picture_index(objects, columns, options)
			end

		end
	end
end