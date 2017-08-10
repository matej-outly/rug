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
		module Columns extend ActiveSupport::Concern

			# *************************************************************
			# Definitions
			# *************************************************************

			included do
				
				# Method for each available type
				RugBuilder::Formatter.types.each do |type|
					define_method(type) do |column, options = {}|
						column_options = options
						column_options[:type_options] = options[:type] ? options[:type] : {}
						column_options[:type] = type
						self.columns[column.to_sym] = column_options
						self.add_column(column, options) if self.respond_to?(:add_column, true) 
						return ""
					end
				end

			end

			def custom(column, options = {}, &block)
				column_options = options
				column_options[:type_options] = options[:type] ? options[:type] : {}
				column_options[:type] = :block
				column_options[:block] = block
				self.columns[column.to_sym] = column_options
				self.add_column(column, options) if self.respond_to?(:add_column, true) 
				return ""
			end

			def store(column, options = {})
				column_options = options
				column_options[:type_options] = options[:type] ? options[:type] : {}
				column_options[:type] = :store
				self.columns[column.to_sym] = column_options
				self.add_column(column, options) if self.respond_to?(:add_column, true) 
				return ""
			end

		protected

			# *************************************************************
			# Internal storage
			# *************************************************************

			def clear_columns
				@columns = nil
			end

			def columns
				@columns = {} if @columns.nil?
				return @columns
			end

			# *************************************************************
			# Render
			# *************************************************************

			def render_column_label(column, model_class)
				raise "Unknown column '#{column.to_s}'." if !self.columns[column.to_sym]
				
				if !self.columns[column.to_sym][:label].nil?
					if self.columns[column.to_sym][:label] != false
						return self.columns[column.to_sym][:label].to_s
					else
						return ""
					end
				else
					return model_class.human_attribute_name(column).upcase_first
				end
			end

			def render_column_value(column, object)
				raise "Unknown column '#{column.to_s}'." if !self.columns[column.to_sym]
				
				# Column is defined by block
				if self.columns[column.to_sym][:block]
					block = self.columns[column.to_sym][:block]
					return @template.capture(object, &block).to_s

				# Column is a store
				elsif self.columns[column.to_sym][:type] && self.columns[column.to_sym][:type] == :store
					result = []

					# Get value
					store_value = object.send(column.to_sym)
					if !store_value.nil?
						RugBuilder::Formatter.initialize(@template)
						
						# Go through the store and render each item as string
						store_value.each do |label, single_value|
							if !label.blank? && !single_value.blank?
								result << {
									label: label,
									value: RugBuilder::Formatter.string(single_value, {
										object: object,
										column: column
									})
								}
							end
						end
					end

					return result

				# Column is a standard type renderable by formatter
				elsif self.columns[column.to_sym][:type]

					# Get value
					value = object.send(column.to_sym)
					
					# Set additional options necessary for formatter options
					options = self.columns[column.to_sym][:type_options].dup
					options[:object] = object
					options[:column] = column

					# Call formatter
					RugBuilder::Formatter.initialize(@template)
					return RugBuilder::Formatter.method(self.columns[column.to_sym][:type].to_sym).call(value, options)

				else

					# Unknown
					raise "Don't know how to render column '#{column.to_s}'..."
				end

			end

		end
	end
#end
end