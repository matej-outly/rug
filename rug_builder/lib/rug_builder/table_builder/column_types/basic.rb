# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - basic types
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
			# String
			# *********************************************************************

			def validate_string_options(column_spec)
				return true
			end

			def render_string(column, object)
				value = object.send(column).to_s
				if @columns[column][:no_break] == true
					value = value.gsub(" ", "&nbsp;").html_safe
				end
				return value
			end

			# *********************************************************************
			# Text
			# *********************************************************************

			def validate_text_options(column_spec)
				return true
			end

			def render_text(column, object)
				value = object.send(column)
				return "" if value.blank?

				# Strip tags?
				if @columns[column][:strip_tags] == true
					value = value.strip_tags
				end

				# Truncate?
				if @columns[column][:truncate] != false
					value = value.truncate
				end

				return value.html_safe
			end

			# *********************************************************************
			# Integer
			# *********************************************************************

			def validate_integer_options(column_spec)
				return true
			end

			def render_integer(column, object)
				value = object.send(column)
				if value.nil?
					return ""
				else
					return value.to_i.to_s
				end
			end

			# *********************************************************************
			# Currency
			# *********************************************************************

			def validate_currency_options(column_spec)
				return true
			end

			def render_currency(column, object)
				if @columns[column][:locale]
					locale = @columns[column][:locale]
				else
					locale = :cs
				end
				value = object.send(column)
				return @template.number_to_currency(value, locale: locale)
			end

			# *********************************************************************
			# URL
			# *********************************************************************

			def validate_url_options(column_spec)
				return true
			end

			def render_url(column, object)
				url = object.send(column).to_s
				if @columns[column][:label]
					label = @columns[column][:label]
				else
					label = url
				end
				if @columns[column][:target]
					target = @columns[column][:target]
				else
					target = "_self"
				end
				return @template.link_to(label, url, target: target)
			end


		end
	end
end