# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - label
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Render label associated to some column name
			#
			def label_for(name, options = {})
				if !options[:label].nil?
					if options[:label] != false
						return label(name, options[:label], class: "control-label", data: options[:data])
					else
						return ""
					end
				else
					return label(name, class: "control-label", data: options[:data])
				end
			end

		end
#	end
end