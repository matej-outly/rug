# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug icon builder
# *
# * Author: Matěj Outlý
# * Date  : 24. 6. 2016
# *
# *****************************************************************************

module RugBuilder
#	module Gumby
		class IconBuilder

			#
			# Translate standard icon to this framework
			#
			def self.standard_icon(standard_icon)
				return case standard_icon
					when :index then "list"
					when :show then "search"
					when :edit then "pencil"
					when :new then "plus"
					when :destroy then "trash"
					when :move then "arrow-combo"
					when :move_up then "up-dir"
					when :move_down then "down-dir"
					when :duplicate then "duplicate"
					else nil
				end
			end

			#
			# Render icon 
			#
			def self.render(icon)
				icon = self.standard_icon(icon) if !icon.is_a?(String)
				if !icon.blank?
					return "".html_safe # TODO
				else
					return ""
				end
			end

		end
#	end
end