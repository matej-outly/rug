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
			module Utils extend ActiveSupport::Concern

				def model_class
					if @model_class.nil?
						if @options[:model_class]
							@model_class = @options[:model_class].constantize
						elsif @objects.is_a?(ActiveRecord::Relation)
							@model_class = @objects.class.to_s.deconstantize.constantize
						elsif @objects.is_a?(Array) && !@objects.empty?
							@model_class = @objects.first.class
						else
							raise "Please supply model class option or use ActiveRecord::Relation, not empty Array or single ActiveRecord::Base object as collection."
						end
					end
					return @model_class
				end

				def hash
					if @hash.nil?
						@hash = Digest::SHA1.hexdigest(self.model_class.to_s)
					end
					return @hash
				end

				def js_object
					"rug_index_#{self.hash}"
				end

				def css_class
					"index-#{@options[:layout] ? @options[:layout] : "table"}"
				end

				def id
					"index-#{self.hash}"
				end

			end
		end
	end
#end
end