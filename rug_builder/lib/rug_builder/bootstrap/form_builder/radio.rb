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

			def radios_row(name, options = {})
				result = ""
				
				# Attributes
				label_attr = options[:label_attr] || :label
				value_attr = options[:value_attr] || :value

				# Collection
				collection = options[:collection] ? options[:collection] : object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				
				# Enable null option
				if options[:enable_null] == true || options[:enable_null].is_a?(String)
					null_label = options[:enable_null].is_a?(String) ? options[:enable_null] : I18n.t("general.null_option") 
					collection = [OpenStruct.new({value_attr => "", label_attr => null_label})].concat(collection)
				end

				# Enable Bootstrap (Bootstrap is disabled by default)
				enable_bootstrap = (options[:enable_bootstrap] == true)
				
				# Unique hash (must be unique for each object of same type in case we render more edit forms on one page)
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "radios-#{hash}"

				# Value
				value = object.send(name)
				
				# Field
				result += %{<div class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">}
				result += label_for(name, label: options[:label])
				collection.each do |item|
					b_value = item.send(value_attr)
					b_label = item.send(label_attr)
					checked = value && value == b_value
					b_result = %{<div class="#{enable_bootstrap ? "radio" : "radio-no-bootstrap"}">}
					b_result += @template.label_tag("", for: "#{id}-#{b_value}") do
						@template.radio_button_tag("#{object_name}[#{name.to_s}]", b_value, checked, id: "#{id}-#{b_value}") + "<span></span>#{b_label}".html_safe
					end
					b_result += %{</div>}
					result += b_result
				end
				result += errors(name, errors: options[:errors])
				result += %{</div>}

				# Form group
#				result += "<div class=\"#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}\">"
#				result += label_for(name, label: options[:label])
#				result += collection_radio_buttons(name, collection, value_attr, label_attr) do |b|
#					b_result = "<div class=\"#{enable_bootstrap ? "radio" : "radio-no-bootstrap"}\">"
#					b_result += b.label do
#						b.radio_button + "<span></span>#{b.text}".html_safe
#					end
#					b_result += "</div>"
#					b_result.html_safe
#				end
#				result += errors(name, errors: options[:errors])
#				result += "</div>"
				
				return result.html_safe
			end

		end
#	end
end