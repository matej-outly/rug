# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - relation types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class TableBuilder
		class Columns

		protected

			# *********************************************************************
			# Belongs to
			# *********************************************************************

			def validate_belongs_to_options(column_spec)
				return column_spec.key?(:label)
			end

			def render_belongs_to(column, object)
				value = object.send(column)
				return "" if value.blank?
				if @columns[column][:path]
					return "<a href=\"#{RugSupport::PathResolver.new(@template).resolve(@columns[column][:path], value)}\">#{value.send(@columns[column][:label])}</a>"
				else
					return value.send(@columns[column][:label])
				end
			end

			# *********************************************************************
			# Has many
			# *********************************************************************

			def validate_has_many_options(column_spec)
				return column_spec.key?(:label)
			end

			def render_has_many(column, object)
				collection = object.send(column)
				if @columns[column][:path]
					return collection.map { |item| "<a href=\"#{RugSupport::PathResolver.new(@template).resolve(@columns[column][:path], item)}\">#{item.send(@columns[column][:label])}</a>" }.join(", ")
				else
					return collection.map { |item| item.send(@columns[column][:label]) }.join(", ")
				end
			end

		end
	end
end