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
					when :ok then "check"
					when :cancel then "times"
					when :index then "list"
					when :show then "search"
					when :edit then "pencil"
					when :new then "plus"
					when :destroy then "trash"
					when :move then "arrows"
					when :move_up then "long-arrow-up"
					when :move_down then "long-arrow-down"
					when :duplicate then "files-o"
					when :profile then "user"
					when :password then "lock"
					when :recover then "life-ring"
					when :sign_in then "sign-in"
					when :sign_out then "sign-out"
					when :sign_up then "user-plus"
					else nil
				end
			end

			#
			# Render icon 
			#
			def self.render(icon, options = {})
				klass = options[:class] ? options[:class] : ""
				icon = self.standard_icon(icon) if !icon.is_a?(String)
				if !icon.blank?
					return "<i class=\"fa fa-#{icon} #{klass}\"></i> ".html_safe
				else
					return ""
				end
			end

		end
#	end
end