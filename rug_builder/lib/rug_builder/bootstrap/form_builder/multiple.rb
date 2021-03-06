# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - multiple TODO library JS code
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def text_array_row(name, method = :text_field, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "array-#{hash}"

				# Value
				value = options[:value] ? options[:value] : object.send(name)
				value = value.to_json if value && !value.is_a?(String)

				# Builders
				button_builder = RugBuilder::ButtonBuilder.new(@template)
				icon_builder = RugBuilder::IconBuilder.new(@template)

				# Label add
				label_add = options[:label_add] ? options[:label_add] : I18n.t("general.action.new").mb_upcase_first

				# Placeholder
				placeholder = options[:placeholder] ? options[:placeholder] : nil

				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_array_#{hash} = null;
					$(document).ready(function() {
						rug_form_array_#{hash} = new RugFormArray('#{hash}', {
						});
						rug_form_array_#{hash}.ready();
					});
				})

				# Field
				result += %{
					<div id="#{id}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="backend" style="display: none;">
							#{@template.hidden_field_tag("#{object_name}[#{name.to_s}]", value)}
						</div>
						<div class="template" style="display: none;">
							<div class="row">
								<div class="col-sm-10">
									#{@template.method("#{method.to_s}_tag").call("", "", class: "form-control value", placeholder: placeholder)}
								</div>
								<div class="col-sm-2 text-right">
									#{button_builder.button(icon_builder.render(:close), "#", style: "danger", class: "remove")}
								</div>
							</div>
						</div>
						<div class="frontend"></div>
						<div class="panel panel-concept controls">
							#{button_builder.button(icon_builder.render(:new) + label_add, "#", style: "default", class: "add")}
						</div>
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

			def picker_array_row(name, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "array-#{hash}"
				
				# Value
				value = options[:value] ? options[:value] : object.send(name)
				value = value.to_json if value && !value.is_a?(String)
				
				# Builders
				button_builder = RugBuilder::ButtonBuilder.new(@template)
				icon_builder = RugBuilder::IconBuilder.new(@template)

				# Label add
				label_add = options[:label_add] ? options[:label_add] : I18n.t("general.action.new").mb_upcase_first

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

				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_array_#{hash} = null;
					$(document).ready(function() {
						rug_form_array_#{hash} = new RugFormArray('#{hash}', {
						});
						rug_form_array_#{hash}.ready();
					});
				})

				# Field
				result += %{
					<div id="#{id}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="backend" style="display: none;">
							#{@template.hidden_field_tag("#{object_name}[#{name.to_s}]", value)}
						</div>
						<div class="template" style="display: none;">
							<div class="row">
								<div class="col-sm-10">
									#{@template.select_tag("", @template.options_from_collection_for_select(collection, value_attr, label_attr), class: "form-control value")}
								</div>
								<div class="col-sm-2 text-right">
									#{button_builder.button(icon_builder.render(:close), "#", style: "danger", class: "remove")}
								</div>
							</div>
						</div>
						<div class="frontend"></div>
						<div class="panel panel-concept controls">
							#{button_builder.button(icon_builder.render(:new) + label_add, "#", style: "default", class: "add")}
						</div>
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

			def hash_array_row(name, options = {}, &block)
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "array-#{hash}"

				# Value
				value = options[:value] ? options[:value] : object.send(name)
				value = value.to_json if value && !value.is_a?(String)

				# Builders
				button_builder = RugBuilder::ButtonBuilder.new(@template)
				icon_builder = RugBuilder::IconBuilder.new(@template)

				# Label add
				label_add = options[:label_add] ? options[:label_add] : I18n.t("general.action.new").mb_upcase_first

				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_array_#{hash} = null;
					$(document).ready(function() {
						rug_form_array_#{hash} = new RugFormArray('#{hash}', {
						});
						rug_form_array_#{hash}.ready();
					});
				})

				# Field
				result += %{
					<div id="#{id}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="backend" style="display: none;">
							#{@template.hidden_field_tag("#{object_name}[#{name.to_s}]", value)}
						</div>
						<div class="template" style="display: none;">
							#{@template.capture(button_builder, icon_builder, &block).to_s}
						</div>
						<div class="frontend"></div>
						<div class="panel panel-concept controls">
							#{button_builder.button(icon_builder.render(:new) + label_add, "#", style: "default", class: "add")}
						</div>
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

			def store_row(name, method = :text_field, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "store-#{hash}"

				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?

				# Frontend fields options
				key_field_options = {}
				key_field_options[:class] = klass.join(" ") + " key"
				value_field_options = {}
				value_field_options[:class] = klass.join(" ") + " value"

				# Value
				value = options[:value] ? options[:value] : object.send(name)
				value = value.to_json if value && !value.is_a?(String)

				# Builders
				button_builder = RugBuilder::ButtonBuilder.new(@template)
				icon_builder = RugBuilder::IconBuilder.new(@template)

				# Label add
				label_add = options[:label_add] ? options[:label_add] : I18n.t("general.action.new").mb_upcase_first

				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_store_#{hash} = null;
					$(document).ready(function() {
						rug_form_store_#{hash} = new RugFormStore('#{hash}', {
						});
						rug_form_store_#{hash}.ready();
					});
				})

				# Field
				result += %{
					<div id="#{id}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="backend" style="display: none;">
							#{@template.hidden_field_tag("#{object_name}[#{name.to_s}]", value)}
						</div>
						<div class="template" style="display: none;">
							<div class="row">
								<div class="col-sm-4">
									#{@template.method("#{method.to_s}_tag").call("", "", key_field_options)}
								</div>
								<div class="col-sm-6">
									#{@template.method("#{method.to_s}_tag").call("", "", value_field_options)}
								</div>
								<div class="col-sm-2 text-right">
									#{button_builder.button(icon_builder.render(:close), "#", style: "danger", class: "remove")}
								</div>
							</div>
						</div>
						<div class="frontend"></div>
						<div class="panel panel-concept controls">
							#{button_builder.button(icon_builder.render(:new) + label_add, "#", style: "default", class: "add")}
						</div>
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

		end
#	end
end