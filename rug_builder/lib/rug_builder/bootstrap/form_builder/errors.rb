# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - errors
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Render errors associated to some column name
			#
			def errors(name, options = {})

				if options[:format]
					format = options[:format]
				else
					format = :label
				end
				if ![:label, :alert].include?(format)
					raise "Unknown format #{format}."
				end

				result = ""
				if object.errors[name].size > 0
					if format == :label
						result += @template.content_tag(:span, object.errors[name][0], :class => "label-danger label")
					elsif format == :alert
						result += @template.content_tag(:div, object.errors[name][0], :class => "alert-danger alert")
					end
				end
				return result.html_safe
			end

		end
#	end
end