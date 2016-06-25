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
#	module FontAwesome
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
					when :move then "arrows-v"
					when :move_up then "long-arrow-up"
					when :move_down then "long-arrow-down"
					when :duplicate then "files-o"
					else nil
				end
			end

			#
			# Render icon 
			#
			def self.render(icon)
				icon = self.standard_icon(icon) if !icon.is_a?(String)
				if !icon.blank?
					return "<i class=\"fa fa-#{icon}\"></i> ".html_safe
				else
					return ""
				end
			end

		end
#	end
end