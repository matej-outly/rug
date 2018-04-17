# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - help
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Render help associated to some column name
			#
			def help_for(name, options = {})
				if !options[:help].nil?
					return %{<div class="form-text text-muted m-t-sm">#{options[:help].to_s}</div>}
				else
					return ""
				end
			end

		end
#	end
end