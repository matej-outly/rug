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
#	module Bootstrap
		class IndexBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
			end

			def render(options = {}, &block)
				
				# Call nested block to capture rows, headers, heading and footer and its options
				unused = @template.capture(self, &block).to_s

			end

		end
#	end
end