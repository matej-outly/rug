# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - multiple
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def array_row(name, method = :text_field, options = {})
				result = ""
				
				# Label
				result += compose_label(name, options)

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Java Script
				js = %{
					function array_#{hash}_update_back()
					{
						var form_group = $('#array_#{hash}').closest('.form-group');
						var values = [];
						form_group.find('.front .item input').each(function() {
							var value = $(this).val();
							if (value) {
								values.push(value);
							}
						});
						form_group.find('.back input').val(JSON.stringify(values));
					}
					function array_#{hash}_update_front()
					{
						var form_group = $('#array_#{hash}').closest('.form-group');
						var values = JSON.parse(form_group.find('.back input').val());
						if (values instanceof Array) {
							for (var idx = 0; idx < values.length; ++idx) {
								array_#{hash}_add_front(values[idx]);
							}
						}
					}
					function array_#{hash}_add_front(value)
					{
						var form_group = $('#array_#{hash}').closest('.form-group');
						var front = form_group.find('.front');
						var new_item = $('<div class=\\'item\\'>' + form_group.find('.template').html() + '</div>');
						new_item.find('input').val(value);
						new_item.find('input').on('change', array_#{hash}_update_back);
						new_item.find('.remove').on('click', function(e) {
							e.preventDefault();
							$(this).closest('.item').remove();
							array_#{hash}_update_back();
						});
						front.append(new_item);
					}
					function array_#{hash}_ready()
					{
						var form_group = $('#array_#{hash}').closest('.form-group');
						form_group.find('.front .item input').on('change', array_#{hash}_update_back);
						form_group.find('.controls .add').on('click', function(e) {
							e.preventDefault();
							array_#{hash}_add_front('');
						});
						array_#{hash}_update_front();
					}
					$(document).ready(array_#{hash}_ready);
				}
				result += @template.javascript_tag(js)

				# Back field options
				back_field_options = {}
				back_field_options[:id] = "array_" + hash
				
				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?

				# Front field options
				front_field_options = {}
				front_field_options[:class] = klass.join(" ")

				# Value
				value = object.send(name)
				value = value.to_json if value

				# Builders
				button_builder = RugBuilder::ButtonBuilder.new(@template)
				icon_builder = RugBuilder::IconBuilder

				# Field
				result += %{
					<div class="form-group #{(has_error?(name) ? "has-error" : "")}">
						<div class="back" style="display: none;">
							#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value, back_field_options)}
						</div>
						<div class="template" style="display: none;">
							<div class="row">
								<div class="col-sm-11">
									#{@template.method("#{method.to_s}_tag").call(name, "", front_field_options)}
								</div>
								<div class="col-sm-1 text-right">
									#{button_builder.button(icon_builder.render("close"), "#", style: "danger", class: "remove")}
								</div>
							</div>
						</div>
						<div class="front"></div>
						<div class="controls text-right">
							#{button_builder.button(icon_builder.render("plus"), "#", style: "primary", class: "add")}
						</div>
						#{errors(name)}
					</div>
				}

				return result.html_safe
			end

			def store_row(name, method = :text_field, options = {})
				result = ""
				
				# Label
				result += compose_label(name, options)

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Java Script
				js = %{
					function store_#{hash}_update_back()
					{
						var form_group = $('#store_#{hash}').closest('.form-group');
						var values = {};
						form_group.find('.front .item input.key').each(function() {
							var _this = $(this)
							var key = _this.val();
							var value = _this.closest('.item').find('input.value').val()
							if (key) {
								values[key] = value;
							}
						});
						form_group.find('.back input').val(JSON.stringify(values));
					}
					function store_#{hash}_update_front()
					{
						var form_group = $('#store_#{hash}').closest('.form-group');
						var values = JSON.parse(form_group.find('.back input').val());
						if (values instanceof Object) {
							for (var key in values) {
								if (values.hasOwnProperty(key)) {
									store_#{hash}_add_front(key, values[key]);
								}
							}
						}
					}
					function store_#{hash}_add_front(key, value)
					{
						var form_group = $('#store_#{hash}').closest('.form-group');
						var front = form_group.find('.front');
						var new_item = $('<div class=\\'item\\'>' + form_group.find('.template').html() + '</div>');
						new_item.find('input.key').val(key);
						new_item.find('input.value').val(value);
						new_item.find('input').on('change', store_#{hash}_update_back);
						new_item.find('.remove').on('click', function(e) {
							e.preventDefault();
							$(this).closest('.item').remove();
							store_#{hash}_update_back();
						});
						front.append(new_item);
					}
					function store_#{hash}_ready()
					{
						var form_group = $('#store_#{hash}').closest('.form-group');
						form_group.find('.front .item input').on('change', store_#{hash}_update_back);
						form_group.find('.controls .add').on('click', function(e) {
							e.preventDefault();
							store_#{hash}_add_front('','');
						});
						store_#{hash}_update_front();
					}
					$(document).ready(store_#{hash}_ready);
				}
				result += @template.javascript_tag(js)

				# Back field options
				back_field_options = {}
				back_field_options[:id] = "store_" + hash
				
				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?

				# Front fields options
				front_key_field_options = {}
				front_key_field_options[:class] = klass.join(" ") + " key"
				front_value_field_options = {}
				front_value_field_options[:class] = klass.join(" ") + " value"

				# Value
				value = object.send(name)
				value = value.to_json if value

				# Builders
				button_builder = RugBuilder::ButtonBuilder.new(@template)
				icon_builder = RugBuilder::IconBuilder

				# Field
				result += %{
					<div class="form-group #{(has_error?(name) ? "has-error" : "")}">
						<div class="back" style="display: none;">
							#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value, back_field_options)}
						</div>
						<div class="template" style="display: none;">
							<div class="row">
								<div class="col-sm-4">
									#{@template.method("#{method.to_s}_tag").call(name, "", front_key_field_options)}
								</div>
								<div class="col-sm-7">
									#{@template.method("#{method.to_s}_tag").call(name, "", front_value_field_options)}
								</div>
								<div class="col-sm-1 text-right">
									#{button_builder.button(icon_builder.render("close"), "#", style: "danger", class: "remove")}
								</div>
							</div>
						</div>
						<div class="front"></div>
						<div class="controls text-right">
							#{button_builder.button(icon_builder.render("plus"), "#", style: "primary", class: "add")}
						</div>
						#{errors(name)}
					</div>
				}

				return result.html_safe
			end

		end
#	end
end