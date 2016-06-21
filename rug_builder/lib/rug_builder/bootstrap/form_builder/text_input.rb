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

				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label], class: "control-label")
					end
				else
					result += label(name, class: "control-label")
				end

				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				# Field options
				field_options = {}
				field_options[:class] = klass.join(" ")
				field_options[:id] = options[:id] if !options[:id].nil?
				field_options[:value] = options[:value] if !options[:value].nil?
				field_options[:placeholder] = options[:placeholder] if !options[:placeholder].nil?
				field_options[:min] = options[:min] if !options[:min].nil?
				field_options[:max] = options[:max] if !options[:max].nil?
				
				# Localization
				if options[:localization].nil? || options[:localization] == false
					localization = [nil]
					is_localized = false
				else
					if options[:localization].is_a?(Array)
						localization = options[:localization]
					else
						localization = I18n.available_locales
					end
					is_localized = true
				end

				# Tab header
				if is_localized
					result += "<section class=\"tabs pill minimal\">"
					result += "<ul class=\"tab-nav\">"
					localization.each_with_index do |locale, index|
						result += "<li class=\"#{(index == 0 ? "active" : "")}\"><a href=\"#\">#{locale.to_s.upcase}</a></li>"
					end
					result += "</ul>"
				end

				localization.each_with_index do |locale, index|
					
					# Tab content
					if is_localized
						result += "<div class=\"tab-content #{(index == 0 ? "active" : "")}\">"
						suffixed_name = (name.to_s + "_#{locale.to_s}").to_sym
					else
						suffixed_name = name
					end

					# Form group
					result += "<div class=\"form-group #{(object.errors[suffixed_name].size > 0 ? "has-error" : "")}\">"
				
					# Field
					result += self.method(method).call(suffixed_name, field_options)
					
					# Errors
					if object.errors[suffixed_name].size > 0
						result += @template.content_tag(:span, object.errors[suffixed_name][0], :class => "label-danger label")
					end

					# Form group
					result += "</div>"

					# Tab content
					if is_localized
						result += "</div>"
					end

				end

				if is_localized
					result += "</section>"
				end

				return result.html_safe
			end

			def address_row(name, options = {})
				result = "<div class=\"form-horizontal\">"
				
				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label], class: "control-label")
					end
				else
					result += label(name, class: "control-label")
				end

				# Part labels
				label_street = (options[:label_street] ? options[:label_street] : I18n.t("general.attribute.address.street"))
				label_number = (options[:label_number] ? options[:label_number] : I18n.t("general.attribute.address.number"))
				label_city = (options[:label_city] ? options[:label_city] : I18n.t("general.attribute.address.city"))
				label_postcode = (options[:label_postcode] ? options[:label_postcode] : I18n.t("general.attribute.address.postcode"))
				
				# Part values
				value = object.send(name)
				value_street = value && value[:street] ? value[:street] : nil
				value_number = value && value[:number] ? value[:number] : nil
				value_city = value && value[:city] ? value[:city] : nil
				value_postcode = value && value[:postcode] ? value[:postcode] : nil

				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				# Form group
				result += "<div class=\"form-group #{(object.errors[name].size > 0 ? "has-error" : "")}\">"
				
				# Inputs (first row)
				result += "<div class=\"col-sm-8\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_street.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][street]", value_street, class: klass)
				result += "</div></div>"

				result += "<div class=\"col-sm-4\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_number.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][number]", value_number, class: klass)
				result += "</div></div>"

				# Inputs (second row)
				result += "<div class=\"col-sm-8\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_city.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][city]", value_city, class: klass)
				result += "</div></div>"

				result += "<div class=\"col-sm-4\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_postcode.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][postcode]", value_postcode, class: klass)
				result += "</div></div>"

				# Errors
				if object.errors[name].size > 0
					result += "<div class=\"col-sm-12\">"
					result += @template.content_tag(:span, object.errors[name][0], :class => "label-danger label")
					result += "</div>"
				end

				# Form group
				result += "</div>"

				result += "</div>"
				return result.html_safe
			end

			def name_row(name, options = {})
				result = "<div class=\"form-horizontal\">"
				
				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label], class: "control-label")
					end
				else
					result += label(name, class: "control-label")
				end

				# Part labels
				label_title = (options[:label_title] ? options[:label_title] : I18n.t("general.attribute.name.title")) if options[:title] == true
				label_firstname = (options[:label_firstname] ? options[:label_firstname] : I18n.t("general.attribute.name.firstname"))
				label_lastname = (options[:label_lastname] ? options[:label_lastname] : I18n.t("general.attribute.name.lastname"))
				
				# Part values
				value = object.send(name)
				value_title = value && value[:title] ? value[:title] : nil if options[:title] == true
				value_firstname = value && value[:firstname] ? value[:firstname] : nil
				value_lastname = value && value[:lastname] ? value[:lastname] : nil
				
				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?

				# Form group
				result += "<div class=\"form-group #{( object.errors[name].size > 0 ? "has-error" : "")}\">"
				
				# Layout
				if options[:title] == true
					columns_layout = [4, 4, 4]
				else
					columns_layout = [nil, 6, 6]
				end

				# Inputs
				if options[:title] == true
					result += "<div class=\"col-sm-#{columns_layout[0]}\"><div class=\"input-group\">"
					result += "<div class=\"input-group-addon\">#{label_title.upcase_first}</div>"
					result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][title]", value_title, class: klass)
					result += "</div></div>"
				end
				
				result += "<div class=\"col-sm-#{columns_layout[1]}\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_firstname.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][firstname]", value_firstname, class: klass)
				result += "</div></div>"

				result += "<div class=\"col-sm-#{columns_layout[2]}\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_lastname.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][lastname]", value_lastname, class: klass)
				result += "</div></div>"
				
				# Errors
				if object.errors[name].size > 0
					result += "<div class=\"col-sm-12\">"
					result += @template.content_tag(:span, object.errors[name][0], :class => "label-danger label")
					result += "</div>"
				end

				# Form group
				result += "</div>"

				result += "</div>"
				return result.html_safe
			end

			def range_row(name, method = :number_field, options = {})
				result = "<div class=\"form-horizontal\">"
				
				# Label
				if !options[:label].nil?
					if options[:label] != false
						result += label(name, options[:label], class: "control-label")
					end
				else
					result += label(name, class: "control-label")
				end

				# Part labels
				label_min = (options[:label_min] ? options[:label_min] : I18n.t("general.attribute.range.min"))
				label_max = (options[:label_max] ? options[:label_max] : I18n.t("general.attribute.range.max"))
				
				# Part values
				value = object.send(name)
				value_min = value && value[:min] ? value[:min] : nil
				value_max = value && value[:max] ? value[:max] : nil
				
				# CSS class
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				# Form group
				result += "<div class=\"form-group #{( object.errors[name].size > 0 ? "has-error" : "")}\">"
				
				# Inputs
				result += "<div class=\"col-sm-6\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_min.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][min]", value_min, class: klass)
				result += "</div></div>"

				result += "<div class=\"col-sm-6\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_max.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][max]", value_max, class: klass)
				result += "</div></div>"

				# Errors
				if object.errors[name].size > 0
					result += "<div class=\"col-sm-12\">"
					result += @template.content_tag(:span, object.errors[name][0], :class => "label-danger label")
					result += "</div>"
				end

				# Form group
				result += "</div>"

				result += "</div>"
				return result.html_safe
			end

		end
#	end
end