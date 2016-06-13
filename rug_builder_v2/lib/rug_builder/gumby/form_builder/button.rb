# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - button
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Gumby
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Render primary button or submit
			#
			def primary_button_row(method = :submit, options = {})
				if !options[:label].nil?
					return "<div class=\"element\"><div class=\"medium primary btn\">#{self.method(method).call(options[:label])}</div></div>".html_safe
				else
					return "<div class=\"element\"><div class=\"medium primary btn\">#{self.method(method).call}</div></div>".html_safe
				end
			end

		end
#	end
end