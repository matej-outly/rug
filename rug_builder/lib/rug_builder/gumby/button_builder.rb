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
#	module Gumby
		class ButtonBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
			end

			#
			# Render button 
			#
			def button(label, url = nil, options = {})
				return "".html_safe # TODO
			end

			#
			# Render button 
			#
			def dropdown_button(label = nil, options = {}, &block)
				return "".html_safe # TODO
			end

			#
			# Render button 
			#
			def button_group(options = {}, &block)
				return "".html_safe # TODO
			end

		end
#	end
end