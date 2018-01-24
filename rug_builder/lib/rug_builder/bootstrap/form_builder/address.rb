# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - address
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def address_row(name, options = {})
				
				# Part labels
				label_street = (options[:label_street] ? options[:label_street] : I18n.t("general.attribute.address.street")) if options[:street] != false
				label_number = (options[:label_number] ? options[:label_number] : I18n.t("general.attribute.address.number")) if options[:number] != false
				label_city = (options[:label_city] ? options[:label_city] : I18n.t("general.attribute.address.city")) if options[:city] != false
				label_zipcode = (options[:label_zipcode] ? options[:label_zipcode] : I18n.t("general.attribute.address.zipcode")) if options[:zipcode] != false
				
				# Part values
				value = object.send(name)
				value_street = value && value[:street] ? value[:street] : nil if options[:street] != false
				value_number = value && value[:number] ? value[:number] : nil if options[:number] != false
				value_city = value && value[:city] ? value[:city] : nil if options[:city] != false
				value_zipcode = value && value[:zipcode] ? value[:zipcode] : nil if options[:zipcode] != false
				
				if options[:street] != false
					result_street = %{
						<div class="col-sm-8 m-b-sm">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_street.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][street]", value_street, class: "form-control street", placeholder: (options[:placeholder] == true ? label_street.upcase_first : nil))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:number] != false
					result_number = %{
						<div class="col-sm-4 m-b-sm">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_number.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][number]", value_number, class: "form-control number", placeholder: (options[:placeholder] == true ? label_number.upcase_first : nil))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:city] != false
					result_city = %{
						<div class="col-sm-8 m-b-sm">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_city.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][city]", value_city, class: "form-control city", placeholder: (options[:placeholder] == true ? label_city.upcase_first : nil))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:zipcode] != false
					result_zipcode = %{
						<div class="col-sm-4 m-b-sm">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_zipcode.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][zipcode]", value_zipcode, class: "form-control zipcode", placeholder: (options[:placeholder] == true ? label_zipcode.upcase_first : nil))}
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
							#{options[:zipcode] != false ? result_zipcode : ""}
						</div>
						<div class="row">
							#{errors(name, errors: options[:errors], class: "col-sm-12") }
						</div>
					</div>
				}

				return result.html_safe
			end

			def address_geocoded_row(name, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_address_#{hash} = null;
					$(document).ready(function() {
						rug_form_address_#{hash} = new RugFormAddress('#{hash}', {
						});
						rug_form_address_#{hash}.ready();
					});
				})

				# Part labels
				label_street = (options[:label_street] ? options[:label_street] : I18n.t("general.attribute.address.street")) if options[:street] != false
				label_number = (options[:label_number] ? options[:label_number] : I18n.t("general.attribute.address.number")) if options[:number] != false
				label_city = (options[:label_city] ? options[:label_city] : I18n.t("general.attribute.address.city")) if options[:city] != false
				label_zipcode = (options[:label_zipcode] ? options[:label_zipcode] : I18n.t("general.attribute.address.zipcode")) if options[:zipcode] != false
				
				# Part values
				value = object.send(name)
				value_street = value && value[:street] ? value[:street] : nil if options[:street] != false
				value_number = value && value[:number] ? value[:number] : nil if options[:number] != false
				value_city = value && value[:city] ? value[:city] : nil if options[:city] != false
				value_zipcode = value && value[:zipcode] ? value[:zipcode] : nil if options[:zipcode] != false

				if options[:street] != false
					result_street = %{
						<div class="col-sm-8 m-b-sm">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_street.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][street]", value_street, class: "form-control street", placeholder: (options[:placeholder] == true ? label_street.upcase_first : nil))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:number] != false
					result_number = %{
						<div class="col-sm-4 m-b-sm">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_number.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][number]", value_number, class: "form-control number", placeholder: (options[:placeholder] == true ? label_number.upcase_first : nil))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:city] != false
					result_city = %{
						<div class="col-sm-8 m-b-sm">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_city.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][city]", value_city, class: "form-control city", placeholder: (options[:placeholder] == true ? label_city.upcase_first : nil))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:zipcode] != false
					result_zipcode = %{
						<div class="col-sm-4 m-b-sm">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_zipcode.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][zipcode]", value_zipcode, class: "form-control zipcode", placeholder: (options[:placeholder] == true ? label_zipcode.upcase_first : nil))}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				result += %{
					<div id="address-#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
							#{options[:street] != false ? result_street : ""}
							#{options[:number] != false ? result_number : ""}
						</div>
						<div class="row">
							#{options[:city] != false ? result_city : ""}
							#{options[:zipcode] != false ? result_zipcode : ""}
						</div>
						<div class="suggestions"></div>
						#{errors(name, errors: options[:errors]) }
					</div>
				}

				return result.html_safe
			end

		end
#	end
end