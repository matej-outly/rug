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

# Common concerns
require "rug_builder/bootstrap/concerns/actions"
require "rug_builder/bootstrap/concerns/columns"

# Concerns
require "rug_builder/bootstrap/show_builder/concerns/headers"
require "rug_builder/bootstrap/show_builder/concerns/utils"

# Builders
require "rug_builder/bootstrap/show_builder/builders/header"
require "rug_builder/bootstrap/show_builder/builders/body"
require "rug_builder/bootstrap/show_builder/builders/footer"

module RugBuilder
#module Bootstrap
	class ShowBuilder
		include RugBuilder::ShowBuilder::Concerns::Utils

		def initialize(template)
			@template = template
		end

		def render(object, options = {}, &block)
			@object = object
			@options = options
			result = %{
				<div class="#{self.css_class}">
					#{@template.capture(self, &block).to_s}
				</div>
			}
			return result.html_safe
		end

		def header(options = {}, &block)
			@header = RugBuilder::ShowBuilder::Builders::Header.new(@template)
			return @header.render(@object, @options.merge(options), &block)
		end

		def body(options = {}, &block)
			@body = RugBuilder::ShowBuilder::Builders::Body.new(@template)
			return @body.render(@object, @options.merge(options), &block)
		end

		def footer(options = {}, &block)
			@footer = RugBuilder::ShowBuilder::Builders::Footer.new(@template)
			return @footer.render(@object, @options.merge(options), &block)
		end

	end
#end
end