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

			def picker_row(name, options = {})
				
				# Attributes
				label_attr = options[:label_attr] || :label
				value_attr = options[:value_attr] || :value

				# Collection
				collection = options[:collection] ?  options[:collection] : object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				
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

			def multiselect_row(name, options = {})
				result = ""

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Attributes
				label_attr = options[:label_attr] || :label
				value_attr = options[:value_attr] || :value

				# Collection
				collection = options[:collection] ?  options[:collection] : object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				
				# Java Script
				result += @template.javascript_tag(%{
					function multiselect_#{hash}_ready()
					{
						$('#multiselect_#{hash} select').multiselect({
							templates: {
								li: '<li><a tabindex="0" class="checkbox-no-bootstrap"><label><span></span><span></span></label></a></li>',
							},
							enableHTML: true,
							includeSelectAllOption: true,
							selectAllText: '#{I18n.t("views.multiselect.select_all")}',
							nonSelectedText: '#{I18n.t("views.multiselect.none_selected")}',
							nSelectedText: '#{I18n.t("views.multiselect.selected")}',
							allSelectedText: '#{I18n.t("views.multiselect.all_selected")}',
						});
					}
					$(document).ready(multiselect_#{hash}_ready);
				})

				# Form group
				result += %{
					<div id="multiselect_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div>
							#{collection_select(name, collection, value_attr, label_attr, {}, { multiple: true })}
						</div>
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

			def grouped_multiselect_row(name, options = {})
				result = ""

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Group method
				group_method = options[:group_method] || :children

				# Attributes
				group_label_attr = options[:group_label_attr] || :label
				option_label_attr = options[:option_label_attr] || :label
				option_value_attr = options[:option_value_attr] || :value

				# Collection
				collection = options[:collection] ?  options[:collection] : object.class.method("available_#{name.to_s.pluralize}".to_sym).call
				
				# Java Script
				result += @template.javascript_tag(%{
					function multiselect_#{hash}_ready()
					{
						$('#multiselect_#{hash} select').multiselect({
							templates: {
								li: '<li><a tabindex="0" class="checkbox-no-bootstrap"><label><span></span><span></span></label></a></li>',
								liGroup: '<li class="multiselect-item multiselect-group"><a href="javascript:void(0);" class="checkbox-no-bootstrap"><label><span></span><b></b></label></a></li>',
							},
							enableHTML: true,
							enableClickableOptGroups: true,
							includeSelectAllOption: true,
							selectAllText: '#{I18n.t("views.multiselect.select_all")}',
							nonSelectedText: '#{I18n.t("views.multiselect.none_selected")}',
							nSelectedText: '#{I18n.t("views.multiselect.selected")}',
							allSelectedText: '#{I18n.t("views.multiselect.all_selected")}',
						});
					}
					$(document).ready(multiselect_#{hash}_ready);
				})

				# Form group
				result += %{
					<div id="multiselect_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div>
							#{grouped_collection_select(name, collection, group_method, group_label_attr, option_value_attr, option_label_attr, {}, { multiple: true })}
						</div>
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

		end
#	end
end