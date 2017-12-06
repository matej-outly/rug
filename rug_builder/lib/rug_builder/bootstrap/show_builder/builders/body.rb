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

require "rug_builder/bootstrap/show_builder/builders/layout/table"
require "rug_builder/bootstrap/show_builder/builders/layout/list"

module RugBuilder
#module Bootstrap
	class ShowBuilder
		module Builders
			class Body
				include RugBuilder::ShowBuilder::Concerns::Utils
				include RugBuilder::Concerns::Columns
				include RugBuilder::Concerns::Builders
				include RugBuilder::Concerns::Actions

				def initialize(template)
					@template = template
				end

				# *************************************************************
				# Render
				# *************************************************************

				def render(object, options = {}, &block)
					
					# Save
					@object = object
					@options = options

					# Empty
					@empty = true

					# Capture all columns
					unused = @template.capture(self, &block)

					# Render
					result = ""
					if @options[:layout] == :list
						result = render_as_list
					else
						result = render_as_table
					end
					if @empty
						if @options[:empty_message] != false
							result = %{
								<div class="#{self.css_class}-body empty-message #{@options[:class].to_s}">
									#{I18n.t("views.show.empty")}
								</div>
							}
						else
							result = ""
						end
					end

					return result.html_safe
				end

			end
		end
	end
#end
end