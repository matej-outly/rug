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
					when :show then "clipboard"
					when :edit then "edit"
					when :new then "plus"
					when :destroy then "trash"
					when :move then "arrows-alt"
					when :move_up then "long-arrow-alt-up"
					when :move_down then "long-arrow-alt-down"
					when :duplicate then "clone"
					when :profile then "user"
					when :password then "lock"
					when :recover then "life-ring"
					when :sign_in then "sign-in-alt"
					when :sign_out then "sign-out-alt"
					when :sign_up then "user-plus"
					when :close then "times"
					when :reload then "sync-alt"
					else nil
				end
			end

			#
			# Render icon 
			#
			def self.render(icon, options = {})
				style = options[:style] ? options[:style] : :solid
				klass = options[:class] ? options[:class] : ""
				icon = self.standard_icon(icon) if !icon.is_a?(String)
				if !icon.blank?
					return "<i class=\"fa#{style.to_s[0]} fa-#{icon} #{klass}\"></i> ".html_safe
				else
					return ""
				end
			end

		end
#	end
end