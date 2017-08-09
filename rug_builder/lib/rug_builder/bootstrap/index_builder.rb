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
require "rug_builder/bootstrap/index_builder/concerns/partial"
require "rug_builder/bootstrap/index_builder/concerns/utils"

# Builders
require "rug_builder/bootstrap/index_builder/builders/header"
require "rug_builder/bootstrap/index_builder/builders/body"
require "rug_builder/bootstrap/index_builder/builders/footer"

module RugBuilder
#module Bootstrap
	class IndexBuilder
		include RugBuilder::IndexBuilder::Concerns::Utils
		include RugBuilder::IndexBuilder::Concerns::Partial
		include RugBuilder::Concerns::Builders
		
		def initialize(template)
			@template = template
		end

		def render(objects, options = {}, &block)
			
			# Objects
			if objects.is_a?(ActiveRecord::Relation) || objects.is_a?(Array)
				@objects = objects
			elsif objects.is_a?(ActiveRecord::Base)
				@objects = [objects]
			else
				raise "Please provide ActiveRecord::Relation, Array or single ActiveRecord::Base object as collection."
			end

			# Options
			@options = options
			
			# Render entire index
			result = %{
				<div class="#{self.css_class}">
					#{@template.capture(self, &block).to_s}
				</div>
			}

			# Render entire index of captured partial
			if @options[:partial] == true
				return self.render_partial
			else
				return result.html_safe
			end
		end

		def header(options = {}, &block)
			header = RugBuilder::IndexBuilder::Builders::Header.new(@template)
			return header.render(@objects, @options.merge(options), &block)
		end

		def body(options = {}, &block)
			body = RugBuilder::IndexBuilder::Builders::Body.new(@template)
			return self.capture_partial(body.render(@objects, @options.merge(options), &block))
		end

		def footer(options = {}, &block)
			footer = RugBuilder::IndexBuilder::Builders::Footer.new(@template)
			return footer.render(@objects, @options.merge(options), &block)
		end

	end
#end
end