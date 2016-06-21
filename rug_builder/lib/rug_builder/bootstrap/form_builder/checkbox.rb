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

			def checkboxes_row(name, collection = nil, value_attr = :value, label_attr = :label, options = {})
				result = ""
				
				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label], class: "control-label")
					end
				else
					result += label(name, class: "control-label")
				end

				# Enable Bootstrap (Bootstrap is disabled by default)
				if options[:enable_bootstrap] == true
					enable_bootstrap = true
				else
					enable_bootstrap = false
				end

				# Form group
				result += "<div class=\"form-group #{( object.errors[name].size > 0 ? "has-error" : "")}\">"
				
				if collection.nil?
					collection = object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				end
				result += collection_check_boxes(name, collection, value_attr, label_attr) do |b|
					b_result = "<div class=\"#{enable_bootstrap ? "checkbox" : "checkbox-no-bootstrap"}\">"
					b_result += b.label do
						b.check_box + "<span></span>&nbsp;&nbsp;#{b.text}".html_safe
					end
					b_result += "</div>"
					b_result
				end

				# Errors
				if object.errors[name].size > 0
					result += @template.content_tag(:span, object.errors[name][0], :class => "label-danger label")
				end

				# Form group
				result += "</div>"

				return result.html_safe
			end

			def checkbox_row(name, options = {})
				result = ""
				
				# Enable Bootstrap (Bootstrap is disabled by default)
				if options[:enable_bootstrap] == true
					enable_bootstrap = true
				else
					enable_bootstrap = false
				end

				# Form group
				result += "<div class=\"form-group #{(object.errors[name].size > 0 ? "has-error" : "")}\">"
				
				# Label
				label = !options[:label].nil? ? options[:label] : object.class.human_attribute_name(name)
				
				# Field
				result += "<div class=\"#{enable_bootstrap ? "checkbox" : "checkbox-no-bootstrap"}\">"
				result += label(name) do
					check_box(name) + "<span></span>&nbsp;&nbsp;#{label}".html_safe
				end
				result += "</div>"
				
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