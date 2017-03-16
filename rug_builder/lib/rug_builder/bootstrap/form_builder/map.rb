# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - map TODO Google API with key...
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def map_location_row(name, options = {})
				result = ""
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)
				
				# Part labels
				label_latitude = (options[:label_latitude] ? options[:label_latitude] : I18n.t("general.attribute.geolocation.latitude"))
				label_longitude = (options[:label_longitude] ? options[:label_longitude] : I18n.t("general.attribute.geolocation.longitude"))
				
				# Part values
				value = object.send(name)
				value_latitude = value && value[:latitude] ? value[:latitude] : nil
				value_longitude = value && value[:longitude] ? value[:longitude] : nil
				
				# Field options
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
	
				# Google Map API
				result += "<script src=\"https://maps.googleapis.com/maps/api/js?key=#{options[:api_key]}\"></script>"
				
				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_map_location_#{hash} = null;
					$(document).ready(function() {
						rug_form_map_location_#{hash} = new RugFormMapLocation('#{hash}', {
							latitude: #{options[:latitude] ? options[:latitude] : "null"},
							longitude: #{options[:longitude] ? options[:longitude] : "null"},
							zoom: #{options[:zoom] ? options[:zoom] : "null"}
						});
						rug_form_map_location_#{hash}.ready();
					});
				})
				
				# Form group
				result += "<div id=\"map_location_#{hash}\" class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"

				# Label
				result += label_for(name, options)

				# Form horizontal
				result += "<div class=\"form-horizontal\">"
				
				# Text inputs
				result += "<div class=\"col-sm-6\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_latitude.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][latitude]", value_latitude, class: klass.dup.concat(["latitude"]))
				result += "</div></div>"

				result += "<div class=\"col-sm-6\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_longitude.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][longitude]", value_longitude, class: klass.dup.concat(["longitude"]))
				result += "</div></div>"

				# Mapbox (canvas)
				result += "<div class=\"col-sm-12\">"
				result += "<div class=\"mapbox\"></div>"
				result += "</div>"

				# Errors
				result += errors(name, class: "col-sm-12")
				
				# Form hotrizontal
				result += "</div>"

				# Form group
				result += "</div>"
				
				return result.html_safe
			end

			def map_polygon_row(name, options = {})
				result = ""
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Part values
				value = object.send(name)

				# Google Map API
				result += "<script src=\"https://maps.googleapis.com/maps/api/js?key=#{options[:api_key]}\"></script>"
				
				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_map_polygon_#{hash} = null;
					$(document).ready(function() {
						rug_form_map_polygon_#{hash} = new RugFormMapPolygon('#{hash}', {
							latitude: #{options[:latitude] ? options[:latitude] : "null"},
							longitude: #{options[:longitude] ? options[:longitude] : "null"},
							zoom: #{options[:zoom] ? options[:zoom] : "null"}
						});
						rug_form_map_polygon_#{hash}.ready();
					});
				})
				
				# Form group
				result += "<div id=\"map_polygon_#{hash}\" class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"
				
				# Label
				result += label_for(name, options)

				# Form horizontal
				result += "<div class=\"form-horizontal\">"
				
				# Input
				result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value.to_json)

				# Mapbox (canvas)
				result += "<div class=\"col-sm-12\">"
				result += "<div class=\"mapbox\"></div>"
				result += "</div>"

				# Errors
				result += errors(name, class: "col-sm-12")
				
				# Form horizontal
				result += "</div>"

				# Form group
				result += "</div>"
				
				return result.html_safe
			end

			def address_location_row(name, options = {})
				result = ""
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Part values
				value = object.send(name)
				value_latitude = value && value[:latitude] ? value[:latitude] : nil
				value_longitude = value && value[:longitude] ? value[:longitude] : nil
				value_level = value && value[:level] ? value[:level] : nil
				value_address = value && value[:address] ? value[:address] : nil
				
				# Address field options
				field_options = {}
				klass = []
				klass << "form-control address"
				klass << options[:class] if !options[:class].nil?
				field_options[:class] = klass.join(" ")
				
				# Java Script
				#js = ""
				
				# TODO sofar must be done in application JS

				#result += "<script src=\"https://maps.googleapis.com/maps/api/js?key=#{options[:api_key]}\"></script>"
				#result += @template.javascript_tag(js)
				
				# Form group
				result += "<div id=\"address_location_#{hash}\" class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"
				
				# Label
				result += label_for(name, options)
				
				# Form horizontal
				result += "<div class=\"form-horizontal\">"
				
				# Level input
				result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][level]", value_level, class: "level")
				
				# Location inputs
				result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][latitude]", value_latitude, class: "latitude")
				result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][longitude]", value_longitude, class: "longitude")
				
				# Address input
				result += "<div class=\"col-sm-12\">"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][address]", value_address, field_options)
				result += "</div>"
				
				# Errors
				result += errors(name, class: "col-sm-12")
				
				# Form horizontal
				result += "</div>"

				# Form group
				result += "</div>"
				
				return result.html_safe
			end

		end
#	end
end