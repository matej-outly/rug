# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug index builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	class IndexBuilder
		module Concerns
			module Headers extend ActiveSupport::Concern

				included do
					[:h1, :h2, :h3, :h4, :h5, :h6].each do |tag|
						define_method(tag) do |label|
							%{<#{tag}>#{label}</#{tag}>}.html_safe
						end
					end
				end

			end
		end
	end
#end
end