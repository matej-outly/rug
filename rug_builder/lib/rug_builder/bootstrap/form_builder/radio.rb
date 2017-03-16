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
				
				# Collection
				collection = object.class.method("available_#{name.to_s.pluralize}".to_sym).call if collection.nil?
				
				# Enable null option
				if options[:enable_null] == true || options[:enable_null].is_a?(String)
					null_label = options[:enable_null].is_a?(String) ? options[:enable_null] : I18n.t("general.null_option") 
					collection = [OpenStruct.new({value_attr => "", label_attr => null_label})].concat(collection)
				end

				# Enable Bootstrap (Bootstrap is disabled by default)
				enable_bootstrap = (options[:enable_bootstrap] == true)
				
				# Form group
				result += "<div class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"
				result += label_for(name, options)
				result += collection_radio_buttons(name, collection, value_attr, label_attr) do |b|
					b_result = "<div class=\"#{enable_bootstrap ? "radio" : "radio-no-bootstrap"}\">"
					b_result += b.label do
						b.radio_button + "<span></span>&nbsp;&nbsp;#{b.text}".html_safe
					end
					b_result += "</div>"
					b_result.html_safe
				end
				result += errors(name)
				result += "</div>"
				
				return result.html_safe
			end

		end
#	end
end