# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

# Parts
require "rug_builder/table_builder/column_types/address"
require "rug_builder/table_builder/column_types/array"
require "rug_builder/table_builder/column_types/basic"
require "rug_builder/table_builder/column_types/datetime"
require "rug_builder/table_builder/column_types/enum"
require "rug_builder/table_builder/column_types/file"
require "rug_builder/table_builder/column_types/geo"
require "rug_builder/table_builder/column_types/range"
require "rug_builder/table_builder/column_types/relation"

module RugBuilder
	class TableBuilder
		class Columns

			#
			# Constructor
			#
			def initialize(columns = {})
				@columns = {}
				columns.each do |column, column_spec|
					add_column_by_type(column, column_spec)
				end
			end

			def template=(template)
				@template = template
			end

			def template
				return template			
			end

			# *********************************************************************
			# Additional definition
			# *********************************************************************

			def add_column_by_type(column, column_spec)
				
				# Normalize
				if column_spec.rug_is_a_scalar? # Column spec is directly a column type
					column_spec = { type: column_spec.to_sym }
				elsif column_spec.is_a? Hash # Column spec hash of other options
					column_spec = column_spec.rug_symbolize_keys
					if column_spec[:type].nil?
						raise "Please define column type"
					end
				else
					raise "Uknown column specification format, expected Hash, symbol, or string"
				end

				# Check type
				if !method("validate_#{column_spec[:type].to_s}_options".to_sym) || !method("render_#{column_spec[:type].to_s}".to_sym)
					raise "Unknown column type '#{column_spec[:type].to_s}'"
				end

				# Check options according to type
				if !method("validate_#{column_spec[:type].to_s}_options".to_sym).call(column_spec)
					raise "Column type '#{column_spec[:type].to_s}' defined incorrectly"
				end

				# Save
				@columns[column.to_sym] = column_spec

			end

			def add_column_by_block(column, &block)
				@columns[column.to_sym] = { block: block }
			end

			# *********************************************************************
			# Render
			# *********************************************************************

			def headers
				return @columns.keys
			end

			def render(column, object)
				if !@columns[column.to_sym]
					raise "Unknown column '#{column.to_s}'"
				end

				if @columns[column.to_sym][:type]
					return method("render_#{@columns[column.to_sym][:type].to_s}".to_sym).call(column.to_sym, object).to_s
				elsif @columns[column.to_sym][:block]
					return @columns[column.to_sym][:block].call(object).to_s
				else
					raise "Don't know how to render column '#{column.to_s}'..."
				end
			end

		end
	end
end
