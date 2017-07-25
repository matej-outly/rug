# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - text input
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def text_input_row(name, method = :text_field, options = {})
				result = ""

				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				# Field options
				field_options = {}
				field_options[:class] = klass.join(" ")
				field_options[:id] = options[:id] if !options[:id].nil?
				field_options[:data] = options[:data] if !options[:data].nil?
				field_options[:value] = options[:value] if !options[:value].nil?
				field_options[:placeholder] = options[:placeholder] if !options[:placeholder].nil?
				field_options[:min] = options[:min] if !options[:min].nil?
				field_options[:max] = options[:max] if !options[:max].nil?
				field_options[:step] = options[:step] if !options[:step].nil?
				
				# Unit => suffix
				options[:suffix] = options[:unit] if options[:unit]

				# Form group
				result += "<div class=\"#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}\">"

				# Label
				result += label_for(name, label: options[:label])

				# Input group
				result += "<div class=\"input-group\">" if options[:prefix] || options[:suffix]
				
				# Prefix
				result += "<span class=\"input-group-addon\">#{options[:prefix]}</span>" if options[:prefix]
				
				# Field
				result += self.method(method).call(name, field_options)
				
				# Suffix
				result += "<span class=\"input-group-addon\">#{options[:suffix]}</span>" if options[:suffix]
				
				# Input group
				result += "</div>" if options[:prefix] || options[:suffix]
			
				# Errors
				result += errors(name, errors: options[:errors])
				
				# Form group
				result += "</div>"

				return result.html_safe
			end

			def address_row(name, options = {})
				
				# Part labels
				label_street = (options[:label_street] ? options[:label_street] : I18n.t("general.attribute.address.street")) if options[:street] != false
				label_number = (options[:label_number] ? options[:label_number] : I18n.t("general.attribute.address.number")) if options[:number] != false
				label_city = (options[:label_city] ? options[:label_city] : I18n.t("general.attribute.address.city")) if options[:city] != false
				label_postcode = (options[:label_postcode] ? options[:label_postcode] : I18n.t("general.attribute.address.postcode")) if options[:postcode] != false
				
				# Part values
				value = object.send(name)
				value_street = value && value[:street] ? value[:street] : nil if options[:street] != false
				value_number = value && value[:number] ? value[:number] : nil if options[:number] != false
				value_city = value && value[:city] ? value[:city] : nil if options[:city] != false
				value_postcode = value && value[:postcode] ? value[:postcode] : nil if options[:postcode] != false

				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				if options[:street] != false
					result_street = %{
						<div class="col-sm-8">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_street.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][street]", value_street, class: klass)}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:number] != false
					result_number = %{
						<div class="col-sm-4">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_number.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][number]", value_number, class: klass)}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:city] != false
					result_city = %{
						<div class="col-sm-8">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_city.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][city]", value_city, class: klass)}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:postcode] != false
					result_postcode = %{
						<div class="col-sm-4">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_postcode.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][postcode]", value_postcode, class: klass)}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				result = %{
					<div class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
							#{options[:street] != false ? result_street : ""}
							#{options[:number] != false ? result_number : ""}
						</div>
						<div class="row">
							#{options[:city] != false ? result_city : ""}
							#{options[:postcode] != false ? result_postcode : ""}
						</div>
						<div class="row">
							#{errors(name, errors: options[:errors], class: "col-sm-12") }
						</div>
					</div>
				}

				return result.html_safe
			end

			def name_row(name, options = {})
				
				# Part labels
				label_title = (options[:label_title] ? options[:label_title] : I18n.t("general.attribute.name.title")) if options[:title] == true
				label_firstname = (options[:label_firstname] ? options[:label_firstname] : I18n.t("general.attribute.name.firstname")) if options[:firstname] != false
				label_lastname = (options[:label_lastname] ? options[:label_lastname] : I18n.t("general.attribute.name.lastname")) if options[:lastname] != false
				label_title_after = (options[:label_title_after] ? options[:label_title_after] : I18n.t("general.attribute.name.title_after")) if options[:title_after] == true

				# Part values
				value = object.send(name)
				value_title = value && value[:title] ? value[:title] : nil if options[:title] == true
				value_firstname = value && value[:firstname] ? value[:firstname] : nil if options[:firstname] != false
				value_lastname = value && value[:lastname] ? value[:lastname] : nil if options[:lastname] != false
				value_title_after = value && value[:title_after] ? value[:title_after] : nil if options[:title_after] == true
				
				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				# Layout
				if options[:title] == true || options[:title_after] == true
					if options[:title] == true && options[:title_after] == true
						if options[:firstname] != false && options[:lastname] != false
							columns_layout_core = [4, 4]
						elsif options[:firstname] != false
							columns_layout_core = [8, nil]
						elsif options[:lastname] != false
							columns_layout_core = [nil, 8]
						else
							columns_layout_core = [nil, nil]
						end
					else
						if options[:firstname] != false && options[:lastname] != false
							columns_layout_core = [5, 5]
						elsif options[:firstname] != false
							columns_layout_core = [10, nil]
						elsif options[:lastname] != false
							columns_layout_core = [nil, 10]
						else
							columns_layout_core = [nil, nil]
						end
					end
					columns_layout = [2, columns_layout_core[0], columns_layout_core[1], nil] if options[:title] == true && options[:title_after] != true
					columns_layout = [nil, columns_layout_core[0], columns_layout_core[1], 2] if options[:title] != true && options[:title_after] == true
					columns_layout = [2, columns_layout_core[0], columns_layout_core[1], 2] if options[:title] == true && options[:title_after] == true
				else
					if options[:firstname] != false && options[:lastname] != false
						columns_layout_core = [6, 6]
					elsif options[:firstname] != false
						columns_layout_core = [12, nil]
					elsif options[:lastname] != false
						columns_layout_core = [nil, 12]
					else
						columns_layout_core = [nil, nil]
					end
					columns_layout = [nil, columns_layout_core[0], columns_layout_core[1], nil]
				end

				# Inputs
				if options[:title] == true
					result_title = %{
						<div class="col-sm-#{columns_layout[0]}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_title.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][title]", value_title, class: klass)}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end
				
				if options[:firstname] != false
					result_firstname = %{
						<div class="col-sm-#{columns_layout[1]}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_firstname.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][firstname]", value_firstname, class: klass)}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:lastname] != false
					result_lastname = %{
						<div class="col-sm-#{columns_layout[2]}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_lastname.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][lastname]", value_lastname, class: klass)}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:title_after] == true
					result_title_after = %{
						<div class="col-sm-#{columns_layout[3]}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_title_after.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][title_after]", value_title_after, class: klass)}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end
				
				result = %{
					<div class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
							#{options[:title] == true ? result_title : ""}
							#{options[:firstname] != false ? result_firstname : ""}
							#{options[:lastname] != false ? result_lastname : ""}
							#{options[:title_after] == true ? result_title_after : ""}
							#{errors(name, errors: options[:errors], class: "col-sm-12") }
						</div>
					</div>
				}
				
				return result.html_safe
			end

			def range_row(name, method = :number_field, options = {})
				
				# Part labels
				label_min = (options[:label_min] ? options[:label_min] : I18n.t("general.attribute.range.min")) if options[:min] != false
				label_max = (options[:label_max] ? options[:label_max] : I18n.t("general.attribute.range.max")) if options[:max] != false
				
				# Part values
				value = object.send(name)
				value_min = value && value[:min] ? value[:min] : nil if options[:min] != false
				value_max = value && value[:max] ? value[:max] : nil if options[:max] != false
				
				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				# Number of columns
				columns_count = 0
				columns_count += 1 if options[:min] != false
				columns_count += 1 if options[:max] != false

				if options[:min] != false
					result_min = %{
						<div class="col-sm-#{12 / columns_count}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_min.upcase_first + "</div>" : ""}
								#{@template.method(method.to_s + "_tag").call("#{object_name}[#{name.to_s}][min]", value_min, class: klass.dup.concat(["min"]))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:max] != false
					result_max = %{
						<div class="col-sm-#{12 / columns_count}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_max.upcase_first + "</div>" : ""}
								#{@template.method(method.to_s + "_tag").call("#{object_name}[#{name.to_s}][max]", value_max, class: klass.dup.concat(["max"]))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				result = %{
					<div id="duration_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
							#{options[:min] != false ? result_min : ""}
							#{options[:max] != false ? result_max : ""}
							#{errors(name, errors: options[:errors], class: "col-sm-12") }
						</div>
					</div>
				}
				
				return result.html_safe
			end

		end
#	end
end