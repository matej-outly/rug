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

module RugBuilder
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
					raise "Please define column type."
				end
			else
				raise "Unknown column specification format, expected Hash, symbol, or string."
			end

			# Check type
			if !Formatter.method(column_spec[:type].to_sym)
				raise "Unknown column type '#{column_spec[:type].to_s}'."
			end

			# Save
			@columns[column.to_sym] = column_spec

		end

		def add_column_by_block(column, column_spec = {}, &block)
			column_spec[:block] = block
			@columns[column.to_sym] = column_spec
		end

		# *********************************************************************
		# Render
		# *********************************************************************

		def label(column, model_class)
			if !@columns[column.to_sym][:column_label].nil?
				if @columns[column.to_sym][:column_label] != false
					return @columns[column.to_sym][:column_label].to_s
				else
					return ""
				end
			else
				return model_class.human_attribute_name(column.to_s).upcase_first
			end
		end

		def headers
			return @columns.keys
		end

		def render(column, object)
			if !@columns[column.to_sym]
				raise "Unknown column '#{column.to_s}'."
			end

			if @columns[column.to_sym][:type]

				# Get value
				value = object.send(column.to_sym)
				
				# Get options
				options = @columns[column.to_sym].dup
				options[:object] = object
				options[:column] = column

				# Call formatter
				Formatter.initialize(@template)
				return Formatter.method(@columns[column.to_sym][:type].to_sym).call(value, options)

			elsif @columns[column.to_sym][:block]

				# Call block
				return @columns[column.to_sym][:block].call(object).to_s
			else

				# Unknown
				raise "Don't know how to render column '#{column.to_s}'..."
			end
		end

	end
end