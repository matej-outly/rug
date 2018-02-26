# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - checkbox
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def checkbox_row(name, options = {})
				result = ""
				
				# Enable Bootstrap (Bootstrap is disabled by default)
				enable_bootstrap = (options[:enable_bootstrap] == true)
				
				# Label
				label = !options[:label].nil? ? options[:label] : object.class.human_attribute_name(name)
				
				# Unique hash (must be unique for each object of same type in case we render more edit forms on one page)
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "checkbox-#{hash}"

				# Value
				value = object.send(name)

				# Field
				result += %{<div class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">}
				result += %{<div class="#{enable_bootstrap ? "checkbox" : "checkbox-no-bootstrap"}">}
				checked = value && value == true
				result += @template.label_tag("", for: id) do
					b_result = @template.hidden_field_tag("#{object_name}[#{name.to_s}]", "0", id: "")
					b_result += @template.check_box_tag("#{object_name}[#{name.to_s}]", "1", checked, id: id) + "<span></span>#{label}".html_safe
					b_result
				end
				result += %{</div>}
				result += errors(name, errors: options[:errors])
				result += %{</div>}

				return result.html_safe
			end

			def checkboxes_row(name, options = {})
				result = ""
				
				# Attributes
				label_attr = options[:label_attr] || :label
				value_attr = options[:value_attr] || :value

				# Collection
				collection = options[:collection] ? options[:collection] : object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				
				# Enable Bootstrap (Bootstrap is disabled by default)
				enable_bootstrap = (options[:enable_bootstrap] == true)

				# Unique hash (must be unique for each object of same type in case we render more edit forms on one page)
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "checkboxes-#{hash}"

				# Value
				value = object.send(name)
				if value && value.is_a?(String)
					begin
						value = JSON.parse(value)
					rescue JSON::ParserError
						value = nil
					end
				end

				# Field
				result += %{<div class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">}
				result += label_for(name, label: options[:label])
				collection.each do |item|
					b_value = item.send(value_attr)
					b_label = item.send(label_attr)
					checked = value && value.is_a?(Array) ? value.map{ |i| i.to_s }.include?(b_value.to_s) : false
					b_result = %{<div class="#{enable_bootstrap ? "checkbox" : "checkbox-no-bootstrap"}">}
					b_result += @template.label_tag("", for: "#{id}-#{b_value}") do
						@template.check_box_tag("#{object_name}[#{name.to_s}][]", b_value, checked, id: "#{id}-#{b_value}") + "<span></span>#{b_label}".html_safe
					end
					b_result += %{</div>}
					result += b_result
				end
				result += errors(name, errors: options[:errors])
				result += %{</div>}

				# Field
#				result += %{<div class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">}
#				result += label_for(name, label: options[:label])
#				result += collection_check_boxes(name, collection, value_attr, label_attr) do |b|
#					b_result = %{<div class="#{enable_bootstrap ? "checkbox" : "checkbox-no-bootstrap"}">}
#					b_result += b.label(for: "#{id}-#{b.value}") do
#						b.check_box(id: "#{id}-#{b.value}") + "<span></span>#{b.text}".html_safe
#					end
#					b_result += %{</div>}
#					b_result.html_safe
#				end
#				result += errors(name, errors: options[:errors])
#				result += %{</div>}

				return result.html_safe
			end

			def parametrized_checkboxes_row(name, method = :text_field, options = {})
				result = ""
				
				# Attributes
				label_attr = options[:label_attr] || :label
				value_attr = options[:value_attr] || :value

				# Collection
				collection = options[:collection] ? options[:collection] : object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				
				# Enable Bootstrap (Bootstrap is disabled by default)
				enable_bootstrap = (options[:enable_bootstrap] == true)

				# Unique hash (must be unique for each object of same type in case we render more edit forms on one page)
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "parametrized-checkboxes-#{hash}"

				# Value
				value = object.send(name)
				value = value.to_json if value && !value.is_a?(String)
				
				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_parametrized_checkboxes_#{hash} = null;
					$(document).ready(function() {
						rug_form_parametrized_checkboxes_#{hash} = new RugFormParametrizedCheckboxes('#{hash}', {
						});
						rug_form_parametrized_checkboxes_#{hash}.ready();
					});
				})

				# Parameter unit
				options[:parameter][:suffix] = options[:parameter][:unit] if options[:parameter] && options[:parameter][:unit]

				# Field
				result += %{<div id="#{id}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">}
				result += label_for(name, label: options[:label])
				result += %{<div class="backend" style="display: none;">}
				result += @template.hidden_field_tag("#{object_name}[#{name.to_s}]", value)
				result += %{</div>}
				result += %{<div class="frontend">}
				collection.each do |item|
					value = item.send(value_attr)
					label = item.send(label_attr)
					b_result = %{<div class="row item">}
					b_result += %{<div class="col-sm-6"><div class="#{enable_bootstrap ? "checkbox" : "checkbox-no-bootstrap"}">}
					b_result += @template.label_tag("", for: "#{id}-#{value}") do
						@template.check_box_tag("", value, false, id: "#{id}-#{value}") + "<span></span>#{label}".html_safe
					end
					b_result += %{</div></div>}
					b_result += %{<div class="col-sm-6 text-right parameter-wrapper">}
					b_result += %{<div class="input-group">} if options[:parameter] && (options[:parameter][:prefix] || options[:parameter][:suffix])
					b_result += %{<span class="input-group-addon">#{options[:parameter][:prefix]}</span>} if options[:parameter] && options[:parameter][:prefix]
					b_result += @template.method("#{method.to_s}_tag").call("", "", { 
						class: "form-control parameter " + (options[:parameter] && options[:parameter][:class] ? options[:parameter][:class] : ""),
						placeholder: (options[:parameter] && options[:parameter][:placeholder] ? options[:parameter][:placeholder] : nil), 
					})
					b_result += %{<span class="input-group-addon">#{options[:parameter][:suffix]}</span>} if options[:parameter] && options[:parameter][:suffix]
					b_result += %{</div>} if options[:parameter] && (options[:parameter][:prefix] || options[:parameter][:suffix])
					b_result += %{</div>}
					b_result += %{</div>}
					result += b_result
				end
				result += %{</div>}
				result += errors(name, errors: options[:errors])
				result += %{</div>}

				return result.html_safe
			end

		end
#	end
end