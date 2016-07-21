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
					return "<a 
						class=\"btn btn-#{style} #{size ? "btn-" + size : ""}\" 
						#{method ? "data-method=\"" + method + "\"" : ""}
						href=\"#{url}\">#{label}</a>".html_safe
				else
					return ""
				end
			end

		end
#	end
end