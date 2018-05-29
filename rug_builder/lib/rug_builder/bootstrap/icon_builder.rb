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
#	module Bootstrap
		class IconBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
			end

			#
			# Translate standard icon to this framework
			#
			def standard_icon(standard_icon)
				return case standard_icon
					when :ok then "ok"
					when :cancel then "remove"
					when :index then "list"
					when :show then "search"
					when :edit then "pencil"
					when :new then "plus"
					when :destroy then "trash"
					when :move then "resize-vertical"
					when :move_up then "arrow-up"
					when :move_down then "arrow-down"
					when :duplicate then "duplicate"
					when :profile then "user"
					when :password then "lock"
					when :recover then "lock"
					when :sign_in then "log-in"
					when :sign_out then "log-out"
					when :sign_up then "user"
					when :close then "remove"
					else nil
				end
			end

			#
			# Render icon 
			#
			def render(icon, options = {})
				options = options.nil? ? {} : options
				klass = options[:class] ? options[:class] : ""
				icon = self.standard_icon(icon) if !icon.is_a?(String)

				# Tooltip
				if !options[:tooltip].nil?
					data = {} if data.nil?
					data[:toggle] = "tooltip"
					data[:placement] = "top"
					data[:container] = "body"
					title = options[:tooltip]
				end

				if !icon.blank?
					return (@template.content_tag(:span, "", 
						class: "glyphicon glyphicon-#{icon} #{klass}", 
						data: data,
						title: title,
						"aria-hidden" => "true"
					) + " ").html_safe
				else
					return ""
				end
			end

		end
#	end
end
