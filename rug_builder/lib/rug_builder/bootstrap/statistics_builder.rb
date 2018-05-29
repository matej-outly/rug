# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug statistics table builder
# *
# * Author: Matěj Outlý
# * Date  : 20. 4. 2017
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class StatisticsBuilder
			
			def initialize(template)
				@template = template
				@path_resolver = RugSupport::PathResolver.new(@template)
				@icon_builder = RugBuilder::IconBuilder.new(@template)
				@options = {}
				@parts = []
			end

			# *****************************************************************
			# Parts
			# *****************************************************************

			def x_axis(&block)
				@options[:x_axis] = {
					block: block
				}
				@parts << :x_axis
			end

			def y_axis(&block)
				@options[:y_axis] = {
					block: block
				}
				@parts << :y_axis
			end

			#
			# Options:
			# - grouping (cell|row|column)
			#
			def values(options = {}, &block)
				@options[:values] = {
					block: block
				}.merge(options)
				@parts << :values
			end

			#
			# Options:
			# - label
			#
			def total(options = {}, &block)
				@options[:total] = {
					block: block
				}.merge(options)
				@parts << :total
			end

			# *****************************************************************
			# Render
			# *****************************************************************

			#
			# Options:
			# - x_axis (array|symbol)
			# - y_axis (array|symbol)
			# - unit
			#
			def render(options = {}, &block)
				@options[:global] = options

				# Hash
				hash = 1

				# Parse axes
				@options[:global][:x_axis] = parse_axis(@options[:global][:x_axis])
				@options[:global][:y_axis] = parse_axis(@options[:global][:y_axis])

				# Call nested block to capture parts and its options
				unused = @template.capture(self, &block).to_s

				# Render parts
				result = ""
				result += %{
					<table id="statistics-#{hash}" class="table statistics">
						#{render_parts}
					</table>
				}
				return result.html_safe
			end

		protected

			def render_parts
				result = ""
				@parts.each do |part|
					if part != :y_axis
						result += self.send("render_#{part}")
					end
				end
				return result
			end

			def render_x_axis
				return %{
					<tr>
						#{@parts.include?(:y_axis) ? render_x_axis_label : ""}
						#{@options[:global][:x_axis].map{ |x_value| render_x_axis_cell(x_value) }.join}
					</tr>
				}
			end

			def render_x_axis_label
				return %{
					<th></th>
				}
			end

			def render_x_axis_cell(x_value)
				return %{
					<th class="statistics-header">#{@template.capture(x_value, &@options[:x_axis][:block]).to_s}</th>
				}
			end

			def render_y_axis_cell(y_value)
				return %{
					<td class="statistics-header">#{@template.capture(y_value, &@options[:y_axis][:block]).to_s}</td>
				}
			end

			def render_values

				# Get values
				@values = []
				if @options[:values][:grouping] == :row
					@options[:global][:y_axis].each do |y_value|
						@values << @options[:values][:block].call(y_value, @options[:global][:x_axis])
						raise "Array of values expected." if !@values.last.is_a?(Array)
						raise "Array of values has wrong length." if @values.last.length != @options[:global][:x_axis].length
					end

				elsif @options[:values][:grouping] == :col
					transposed_values = []
					@options[:global][:x_axis].each do |x_value|
						transposed_values << @options[:values][:block].call(x_value, @options[:global][:y_axis])
						raise "Array of values expected." if !transposed_values.last.is_a?(Array)
						raise "Array of values has wrong length." if transposed_values.last.length != @options[:global][:y_axis].length
					end
					@values = transposed_values.transpose

				else # @options[:values][:grouping] == :cell
					@options[:global][:y_axis].each do |y_value|
						row = []
						@options[:global][:x_axis].each do |x_value|	
							row << @options[:values][:block].call(x_value, y_value)
						end
						@values << row
					end
				end

				# Render
				result = ""
				@options[:global][:y_axis].each_with_index do |y_value, y_index|
					result += render_values_row(y_value, y_index)
				end
				return result
			end

			def render_values_row(y_value, y_index)
				return %{
					<tr>
						#{@parts.include?(:y_axis) ? render_y_axis_cell(y_value) : ""}
						#{@values[y_index].map{ |value| render_values_cell(value) }.join}
					</tr>
				}
			end

			def render_values_cell(value)
				return %{
					<td class="statistics-value">#{value} #{@options[:values][:unit].to_s}</td>
				}
			end

			def render_total
				return %{
					<tr>
						#{@parts.include?(:y_axis) ? render_total_label : ""}
						#{@options[:global][:x_axis].map{ |x_value| render_total_cell(x_value) }.join}
					</tr>
				}
			end

			def render_total_label
				return %{
					<td class="statistics-header">#{@options[:total][:label].to_s}</td>
				}
			end

			def render_total_cell(x_value)
				return %{
					<td class="statistics-total">#{@options[:total][:block].call(x_value)} #{@options[:total][:unit].to_s}</td>
				}
			end

			# *****************************************************************
			# Axis parsing
			# *****************************************************************

			def parse_axis(axis)
				
				# Axis not defined => at least one empty item
				if axis.nil?
					return [nil]
				end

				# Axis is already an array
				if axis.is_a?(Array)
					return axis
				end

				# Axis is a range
				if axis.is_a?(Range)
					first = axis.first
					last = axis.last
					if first > last
						return (last..first).to_a.reverse
					else
						return (first..last).to_a
					end
				end

				# Axis defined by symbol
				if axis.is_a?(Symbol) || axis.is_a?(String)
					axis_method = self.method("#{axis}_axis")
					if axis_method
						return axis_method.call
					end
				end

				raise "Incorrect axis format."
			end

			def months_of_year_axis
				return (1..12).to_a
			end

		end
#	end
end
