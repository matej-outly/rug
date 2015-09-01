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

require "truncate_html"

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
				if !KNOWN_TYPES.include?(column_spec[:type])
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

		protected

			# *********************************************************************
			# Known types
			# *********************************************************************
			
			KNOWN_TYPES = [ :string, :text, :integer, :date, :time, :datetime, :boolean, :file, :picture, :enum, :belongs_to, :has_many, :address, :currency, :array ]

			def validate_string_options(column_spec)
				return true
			end

			def validate_text_options(column_spec)
				return true
			end

			def validate_integer_options(column_spec)
				return true
			end

			def validate_date_options(column_spec)
				return true
			end

			def validate_time_options(column_spec)
				return true
			end

			def validate_datetime_options(column_spec)
				return true
			end

			def validate_boolean_options(column_spec)
				return true
			end

			def validate_enum_options(column_spec)
				return true
			end

			def validate_file_options(column_spec)
				return true
			end

			def validate_picture_options(column_spec)
				return column_spec.key?(:thumb_style)
			end

			def validate_belongs_to_options(column_spec)
				return column_spec.key?(:label)
			end

			def validate_has_many_options(column_spec)
				return column_spec.key?(:label)
			end

			def validate_address_options(column_spec)
				return true
			end

			def validate_currency_options(column_spec)
				return true
			end

			def validate_array_options(column_spec)
				return true
			end

			# *********************************************************************
			# Types rendering
			# *********************************************************************

			def render_string(column, object)
				value = object.send(column)
				return value.to_s
			end

			def render_text(column, object)
				value = object.send(column)
				return "" if value.blank?
				html_string = TruncateHtml::HtmlString.new(value)
				return TruncateHtml::HtmlTruncator.new(html_string, {}).truncate.html_safe
			end

			def render_integer(column, object)
				value = object.send(column)
				return value.to_i.to_s
			end

			def render_date(column, object)
				value = object.send(column)
				return "" if value.blank?
				return I18n.l(value)
			end

			def render_time(column, object)
				value = object.send(column)
				return "" if value.blank?
				return I18n.l(value)
			end

			def render_datetime(column, object)
				value = object.send(column)
				return "" if value.blank?
				return I18n.l(value)
			end

			def render_boolean(column, object)
				value = object.send(column)
				if value == true
					return I18n.t("general.bool_yes")
				else
					return I18n.t("general.bool_no")
				end
			end

			def render_file(column, object)
				value = object.send(column)
				if value.exists?
					return "#{I18n.t("general.bool_yes")} - <a href=\"#{value.url}\">#{I18n.t("general.action.download")}</a>".html_safe
				else
					return I18n.t("general.bool_no")
				end
			end

			def render_picture(column, object)
				value = object.send(column)
				if value.exists?
					return "<img src=\"#{value.url(@columns[column][:thumb_style])}\" />".html_safe
				else
					return I18n.t("general.bool_no")
				end
			end

			def render_enum(column, object)
				value = object.send("#{column.to_s}_obj".to_sym)
				return "" if value.blank?
				return value.label
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

			def render_has_many(column, object)
				collection = object.send(column)
				if @columns[column][:path]
					return collection.map { |item| "<a href=\"#{RugSupport::PathResolver.new(@template).resolve(@columns[column][:path], item)}\">#{item.send(@columns[column][:label])}</a>" }.join(", ")
				else
					return collection.map { |item| item.send(@columns[column][:label]) }.join(", ")
				end
			end

			def render_address(column, object)
				value = object.send("#{column.to_s}_formated".to_sym)
				return value
			end

			def render_currency(column, object)
				value = object.send(column)
				return @template.number_to_currency(value, locale: :cs)
			end

			def render_array(column, object)
				value = object.send("#{column.to_s}_formated".to_sym)
				return value
			end

		end
	end
end
