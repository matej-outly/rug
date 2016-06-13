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
#	module Gumby
		class FormBuilder < ActionView::Helpers::FormBuilder

			def radios_row(name, collection = nil, value_attr = :value, label_attr = :label, options = {})
				result = "<div class=\"element\">"
				
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

				# Enable Gumby (Gumby is disabled by default because of broken event support and other shitty stuff)
				if options[:enable_gumby] == true
					enable_gumby = true
				else
					enable_gumby = false
				end

				# Field
				result += "<div class=\"#{( enable_gumby ? "field" : "field-no-gumby" )} #{( object.errors[name].size > 0 ? "danger" : "")}\">"
				result += collection_radio_buttons(name, collection, value_attr, label_attr) do |b|
					b.label(class: (enable_gumby ? "radio" : "radio-no-gumby")) do
						b.radio_button + "<span></span>&nbsp;&nbsp;#{b.text}".html_safe
					end
				end
				result += "</div>"
				
				# Errors
				if object.errors[name].size > 0
					result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
				end

				result += "</div>"
				return result.html_safe
			end

		end
#	end
end