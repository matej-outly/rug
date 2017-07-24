# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - errors
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Decide if some column has at least one error
			#
			def has_error?(name, options = {})
				if !options[:errors].nil?
					if options[:errors] != false
						name = options[:errors]
					else
						return false
					end
				end
				return (object.errors[name].size > 0)
			end

			#
			# Render errors associated to some column name
			#
			def errors(name, options = {})
				if !options[:errors].nil?
					if options[:errors] != false
						name = options[:errors]
					else
						return ""
					end
				end

				# Format
				if options[:format]
					format = options[:format]
				else
					format = :help_block
				end
				if ![:help_block, :label, :alert].include?(format)
					raise "Unknown format #{format}."
				end

				# CSS class
				klass = options[:class] if !options[:class].nil?

				# Render
				id = (self.options && self.options[:html]) ? "#{self.options[:html][:id]}_#{name}_errors" : ""
				result = "<span class=\"errors #{klass}\" id=\"#{id}\">"
				if has_error?(name)
					if format == :help_block
						object.errors[name].uniq.each do |error_message|
							result += @template.content_tag(:span, error_message, :class => "help-block")
						end
					elsif format == :label
						result += @template.content_tag(:span, object.errors[name][0], :class => "label-danger label")
					elsif format == :alert
						result += @template.content_tag(:span, object.errors[name][0], :class => "alert-danger alert")
					end
				end
				result += "</span>"
				return result.html_safe

			end

		end
#	end
end