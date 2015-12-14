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
				
				# Check format
				if @columns[column][:format]
					format = @columns[column][:format]
				else
					format = :comma
				end
				if ![:comma, :br].include?(format)
					raise "Unknown format #{format}."
				end

				# Get join string according to format
				join_string = case format
					when :comma then ", "
					when :br then "<br/>"
				end

				# Get value and format it
				collection = object.send(column)
				if !collection.blank?
					if @columns[column][:path]
						arr = collection.map { |item| "<a href=\"#{RugSupport::PathResolver.new(@template).resolve(@columns[column][:path], item)}\">#{item.send(@columns[column][:label])}</a>" }
					else
						arr = collection.map { |item| item.send(@columns[column][:label]) }
					end
					return arr.join(join_string)
				else
					return ""
				end
			end

		end
	end
end