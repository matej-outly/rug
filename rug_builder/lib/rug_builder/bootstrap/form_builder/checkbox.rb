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

			def checkboxes_row(name, options = {})
				result = ""
				
				# Attributes
				label_attr = options[:label_attr] || :label
				value_attr = options[:value_attr] || :value

				# Collection
				collection = options[:collection] ?  options[:collection] : object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				

				# Enable Bootstrap (Bootstrap is disabled by default)
				enable_bootstrap = (options[:enable_bootstrap] == true)

				# Form group
				result += "<div class=\"#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}\">"

				# Label
				result += label_for(name, label: options[:label])

				if collection.nil?
					collection = object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				end
				result += collection_check_boxes(name, collection, value_attr, label_attr) do |b|
					b_result = "<div class=\"#{enable_bootstrap ? "checkbox" : "checkbox-no-bootstrap"}\">"
					b_result += b.label do
						b.check_box + "<span></span>#{b.text}".html_safe
					end
					b_result += "</div>"
					b_result.html_safe
				end

				# Errors
				result += errors(name, errors: options[:errors])
				
				# Form group
				result += "</div>"

				return result.html_safe
			end

			def checkbox_row(name, options = {})
				result = ""
				
				# Enable Bootstrap (Bootstrap is disabled by default)
				enable_bootstrap = (options[:enable_bootstrap] == true)

				# Form group
				result += "<div class=\"#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}\">"
				
				# Label
				label = !options[:label].nil? ? options[:label] : object.class.human_attribute_name(name)
				
				# ID (must be unique for each object of same type in case we render more edit forms on one page)
				id = object_name.to_s + (object.id ? "_" + object.id.to_s : "") + "_" + name.to_s

				# Field
				result += "<div class=\"#{enable_bootstrap ? "checkbox" : "checkbox-no-bootstrap"}\">"
				result += label(name, for: id) do
					check_box(name, id: id) + "<span></span>#{label}".html_safe
				end
				result += "</div>"
				
				# Errors
				result += errors(name, errors: options[:errors])
				
				# Form group
				result += "</div>"

				return result.html_safe
			end

		end
#	end
end