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
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Render primary button or submit
			#
			def primary_button_row(method = :submit, options = {})

				# CSS class
				klass = []
				klass << "btn"
				if !options[:style].nil?
					klass << "btn-#{options[:style]}"
				else
					klass << "btn-primary"
				end
				klass << options[:class] if !options[:class].nil?
				
				# Field options
				field_options = {}
				field_options[:class] = klass.join(" ")

				return "<div class=\"form-group\">#{self.method(method).call(options[:label], field_options)}</div>".html_safe
			end

		end
#	end
end