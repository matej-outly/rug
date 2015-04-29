# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Create <%= model_name.singularize.gsub("_", " ") %> migration
# *
# * Author: 
# * Date  : <%= Date.today.strftime("%-d. %-m. %Y") %>
# *
# *****************************************************************************

class Create<%= model_path.to_camel.pluralize %> < ActiveRecord::Migration
	def change
		create_table :<%= model_name.to_snake.pluralize %> do |t|
			t.timestamps null: true
		end
	end
end