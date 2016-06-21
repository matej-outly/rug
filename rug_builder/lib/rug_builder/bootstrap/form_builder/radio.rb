# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - radio
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def radios_row(name, collection = nil, value_attr = :value, label_attr = :label, options = {})
				result = ""
				
				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label], class: "control-label")
					end
				else
					result += label(name, class: "control-label")
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

				# Enable Bootstrap (Bootstrap is disabled by default)
				if options[:enable_bootstrap] == true
					enable_bootstrap = true
				else
					enable_bootstrap = false
				end

				# Form group
				result += "<div class=\"form-group #{( object.errors[name].size > 0 ? "has-error" : "")}\">"
				
				result += collection_radio_buttons(name, collection, value_attr, label_attr) do |b|
					b_result = "<div class=\"#{enable_bootstrap ? "radio" : "radio-no-bootstrap"}\">"
					b_result += b.label do
						b.radio_button + "<span></span>&nbsp;&nbsp;#{b.text}".html_safe
					end
					b_result += "</div>"
					b_result.html_safe
				end
				
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