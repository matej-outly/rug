# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - picker
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def picker_row(name, collection = nil, value_attr = :value, label_attr = :label, options = {})
				result = ""
				
				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label])
					end
				else
					result += label(name)
				end

				# Collection
				if collection.nil?
					collection = object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				end

				# Enable null option
				if options[:enable_null] == true || options[:enable_null].is_a?(String)
					null_label = options[:enable_null].is_a?(String) ? options[:enable_null] : I18n.t("general.null_option") 
					collection = [OpenStruct.new({value_attr => "", label_attr => null_label})].concat(collection)
				end

				# Form group
				result += "<div class=\"form-group #{(object.errors[name].size > 0 ? "has-error" : "")}\">"
				
				# Select
				result += collection_select(name, collection, value_attr, label_attr, {}, class: "form-control")
				
				# Errors
				if object.errors[name].size > 0
					result += @template.content_tag(:span, object.errors[name][0], :class => "label-danger label")
				end
				
				# Form group
				result += "</div>"
				
				return result.html_safe
			end

		end
#	end
end