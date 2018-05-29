# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	module Concerns
		module Builders extend ActiveSupport::Concern

			def path_resolver
				@path_resolver = RugSupport::PathResolver.new(@template) if @path_resolver.nil?
				return @path_resolver
			end

			def icon_builder
				@icon_builder = RugBuilder::IconBuilder.new(@template) if @icon_builder.nil?
				return @icon_builder
			end

			def modal_builder
				@modal_builder = RugBuilder::ModalBuilder.new(@template) if @modal_builder.nil?
				return @modal_builder
			end

		end
	end
#end
end