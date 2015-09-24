# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * ActiveRecord identification
# *
# * Author: Matěj Outlý
# * Date  : 23. 9. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Identification extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Set column which contains identification label
				#
				def identification_label_column(new_column)
					@identification_label_column = new_column			
				end

				#
				# Set column which contains identification label
				#
				def identification_value_column(new_column)
					@identification_value_column = new_column			
				end

				#
				# Get column which contains identification label
				#
				def resolve_identification_label_column(object)
					if @identification_label_column.nil?
						if object.respond_to?(:name)
							@identification_label_column = :name
						elsif object.respond_to?(:title)
							@identification_label_column = :title
						elsif object.respond_to?(:label)
							@identification_label_column = :label
						elsif object.respond_to?(:id)
							@identification_label_column = :id
						else
							raise "Please define one of the following attributes: name, title, label, id; or define identification label with identification_label_column method."
						end
					end
					return @identification_label_column
				end

				#
				# Get column which contains identification value
				#
				def resolve_identification_value_column(object)
					if @identification_value_column.nil?
						if object.respond_to?(:id)
							@identification_value_column = :id
						elsif object.respond_to?(:value)
							@identification_value_column = :value
						else
							raise "Please define one of the following attributes: id, value; or define identification value with identification_value_column method."
						end
					end
					return @identification_value_column
				end

			end

			#
			# Get identification label column
			#
			def identification_value_column
				return self.class.resolve_identification_value_column(self)
			end

			#
			# Get identification value column
			#
			def identification_label_column
				return self.class.resolve_identification_label_column(self)
			end

			#
			# Get identification label
			#
			def identification_value
				return self.send(self.identification_value_column)
			end

			#
			# Get identification value
			#
			def identification_label
				return self.send(self.identification_label_column)
			end
			
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Identification)
