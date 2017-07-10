# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug label builder
# *
# * Author: Matěj Outlý
# * Date  : 20. 7. 2016
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class LabelBuilder

			#
			# Render label 
			#
			def self.render(label, options = {})
				options = options.nil? ? {} : options
				style = options[:style] ? options[:style] : "default"
				color = options[:color] ? options[:color] : nil
				klass = options[:class] ? options[:class] : ""

				if !label.blank?
					return "<span class=\"label label-#{style} #{color ? "color-" + color : ""} #{klass}\">#{label}</span>".html_safe
				else
					return ""
				end
			end

		end
#	end
end