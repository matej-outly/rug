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
				
				# Collection
				collection = object.class.method("available_#{name.to_s.pluralize}".to_sym).call if collection.nil?
				
				# Enable null option
				if options[:enable_null] == true || options[:enable_null].is_a?(String)
					null_label = options[:enable_null].is_a?(String) ? options[:enable_null] : I18n.t("general.null_option") 
					collection = [OpenStruct.new({value_attr => "", label_attr => null_label})].concat(collection)
				end

				# Form group
				result = %{
					<div class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						#{collection_select(name, collection, value_attr, label_attr, {}, class: "form-control")}
						#{errors(name, errors: options[:errors])}
					</div>
				}
				
				return result.html_safe
			end

		end
#	end
end