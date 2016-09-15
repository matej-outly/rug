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
#	module Gumby
		class LabelBuilder

			#
			# Render label 
			#
			def self.render(label, options = {})
				style = options[:style] ? options[:style] : "default"
				
				if !label.blank?
					return "".html_safe # TODO
				else
					return ""
				end
			end

		end
#	end
end