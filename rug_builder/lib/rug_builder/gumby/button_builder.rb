# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug button builder
# *
# * Author: Matěj Outlý
# * Date  : 20. 7. 2016
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class ButtonBuilder

			#
			# Render button 
			#
			def self.render(label, url, options = {})
				style = options[:style] ? options[:style] : "default"
				size = options[:size] ? options[:size] : nil
				method = options[:method] ? options[:method] : nil
				url = "#" if url.blank?

				if !label.blank?
					return "".html_safe # TODO
				else
					return ""
				end
			end

		end
#	end
end