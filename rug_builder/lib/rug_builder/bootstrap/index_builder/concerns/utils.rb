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
						else
							@model_class = @objects.class.to_s.deconstantize
							@model_class = @model_class.constantize if !@model_class.blank?
						end
						if @model_class.blank?
							raise "Please supply model class to options or use ActiveRecord::Relation as collection."
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
					"rug_table_#{self.hash}"
				end

				def css_class
					"index-#{@options[:layout] ? @options[:layout] : "table"}"
				end

				def id
					"index-table-#{self.hash}"
				end

			end
		end
	end
#end
end