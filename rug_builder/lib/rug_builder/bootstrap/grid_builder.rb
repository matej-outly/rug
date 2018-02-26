# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug grid builder
# *
# * Author: Matěj Outlý
# * Date  : 6. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class GridBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
			end

			#
			# Main render method
			#
			def render(options = {}, &block)
				
				# Options
				@options = options.nil? ? {} : options

				# Render
				result = @template.capture(self, &block).to_s 
			
				return result.html_safe
			end

			#
			# Render grid row
			#
			def row(options = {}, &block)
				result = %{
					<div class="row #{options[:class]}">
						#{@template.capture(self, &block).to_s}
					</div>
				}
				return result.html_safe
			end

			#
			# Render grid column
			#
			def col(width, options = {}, &block)

				# Offset
				offset_class = options[:offset] ? "col-md-offset-#{options[:offset]}" : ""

				result = %{
					<div class="col-md-#{width} #{offset_class} #{options[:class]}">
						#{@template.capture(self, &block).to_s}
					</div>
				}
				return result.html_safe
			end

		protected

		end
#	end
end