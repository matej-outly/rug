# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug show builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	class ShowBuilder
		module Concerns
			module Utils extend ActiveSupport::Concern

				def model_class
					if @model_class.nil?
						if @options[:model_class]
							@model_class = @options[:model_class].constantize
						else
							@model_class = @object.class
						end
					end
					return @model_class
				end

				def css_class
					"show-table"
				end

			end
		end
	end
#end
end