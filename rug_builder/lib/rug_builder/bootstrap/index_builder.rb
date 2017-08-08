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

# Common concerns
require "rug_builder/bootstrap/concerns/actions"
require "rug_builder/bootstrap/concerns/columns"
require "rug_builder/bootstrap/concerns/builders"

# Concerns
require "rug_builder/bootstrap/index_builder/concerns/additionals"
require "rug_builder/bootstrap/index_builder/concerns/headers"
require "rug_builder/bootstrap/index_builder/concerns/utils"

# Builders
require "rug_builder/bootstrap/index_builder/builders/header"
require "rug_builder/bootstrap/index_builder/builders/body"
require "rug_builder/bootstrap/index_builder/builders/footer"

module RugBuilder
#module Bootstrap
	class IndexBuilder
		include RugBuilder::IndexBuilder::Concerns::Utils
		include RugBuilder::Concerns::Builders
		
		def initialize(template)
			@template = template
		end

		def render(objects, options = {}, &block)
			@objects = objects
			@options = options
			result = %{
				<div class="#{self.css_class}">
					#{@template.capture(self, &block).to_s}
				</div>
			}
			return result.html_safe
		end

		def header(options = {}, &block)
			header = RugBuilder::IndexBuilder::Builders::Header.new(@template)
			return header.render(@objects, @options.merge(options), &block)
		end

		def body(options = {}, &block)
			body = RugBuilder::IndexBuilder::Builders::Body.new(@template)
			return body.render(@objects, @options.merge(options), &block)
		end

		def footer(options = {}, &block)
			footer = RugBuilder::IndexBuilder::Builders::Footer.new(@template)
			return footer.render(@objects, @options.merge(options), &block)
		end

	end
#end
end