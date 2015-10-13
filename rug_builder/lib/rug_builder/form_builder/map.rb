# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - map
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder

		def map_location_row(name, options = {})
			result = "<div class=\"element\">"
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# Label
			if !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Part labels
			label_latitude = (options[:label_latitude] ? options[:label_latitude] : I18n.t("general.attribute.geolocation.latitude"))
			label_longitude = (options[:label_longitude] ? options[:label_longitude] : I18n.t("general.attribute.geolocation.longitude"))
			
			# Part values
			value = object.send(name)
			value_latitude = value && value[:latitude] ? value[:latitude] : nil
			value_longitude = value && value[:longitude] ? value[:longitude] : nil
			
			# Java Script
			js = ""

			js += "var map_#{hash} = null;\n"
			js += "var map_marker_#{hash} = null;\n"
			
			js += "function map_#{hash}_update_inputs(latitude, longitude)\n"
			js += "{\n"
			js += "	$('#map_#{hash} input.latitude').val(latitude);\n"
			js += "	$('#map_#{hash} input.longitude').val(longitude);\n"
			js += "}\n"
			
			js += "function map_#{hash}_update_map()\n"
			js += "{\n"
			js += "	var latitude = parseFloat($('#map_#{hash} input.latitude').val());\n"
			js += "	var longitude = parseFloat($('#map_#{hash} input.longitude').val());\n"
			js += "	if (latitude && longitude) {\n"
			js += "		map_#{hash}_set_marker(latitude, longitude);\n"
			js += "	} else {\n"
			js += "		map_#{hash}_remove_marker();\n"
			js += "	}\n"
			js += "}\n"
			
			js += "function map_#{hash}_set_marker(latitude, longitude)\n"
			js += "{\n"
			js += "	if (map_marker_#{hash} == null) {\n"
			js += "		map_marker_#{hash} = new google.maps.Marker({\n"
			js += "			map: map_#{hash},\n"
			js += "			draggable: true,\n"
			js += "			position: {lat: latitude, lng: longitude}\n"
			js += "		});\n"
			js += "		map_marker_#{hash}.addListener('dragend', function(event) {\n"
			js += "			map_#{hash}_update_inputs(event.latLng.lat(), event.latLng.lng());\n"
			js += "			map_#{hash}.panTo(event.latLng);\n"
			js += "		});\n"
			js += "		map_marker_#{hash}.addListener('click', function() {\n"
			js += "			map_#{hash}_remove_marker();\n"
			js += "			map_#{hash}_update_inputs(null, null);\n"
			js += "		});\n"
			js += "	} else {\n"
			js += "		map_marker_#{hash}.setPosition({lat: latitude, lng: longitude});\n"
			js += "	}\n"
			js += "	map_#{hash}.panTo({lat: latitude, lng: longitude});\n"
			js += "}\n"
			
			js += "function map_#{hash}_remove_marker()\n"
			js += "{\n"
			js += "	if (map_marker_#{hash} != null) {\n"
			js += "		map_marker_#{hash}.setMap(null);\n"
			js += "		map_marker_#{hash} = null;\n"
			js += "	}\n"
			js += "}\n"
			
			js += "function map_#{hash}_ready()\n"
			js += "{\n"
			js += "	var default_latitude = #{( options[:default_latitude] ? options[:default_latitude] : 50.0596696)};\n"
			js += "	var default_longitude = #{( options[:default_longitude] ? options[:default_longitude] : 14.4656239)};\n"
			js += "	var default_zoom = #{( options[:default_zoom] ? options[:default_zoom] : 9)};\n"
			js += "	var map_canvas = $('#map_#{hash} .mapbox').get(0);\n"
			js += "	var map_position = new google.maps.LatLng(default_latitude, default_longitude);\n"
			js += "	var map_options = {\n"
			js += "		center: map_position,\n"
			js += "		zoom: default_zoom,\n"
			js += "		mapTypeId: google.maps.MapTypeId.ROADMAP,\n"
			js += "	}\n"
			js += "	map_#{hash} = new google.maps.Map(map_canvas, map_options);\n"
			js += "	google.maps.event.addListener(map_#{hash}, 'click', function(event) {\n"
			js += "		map_#{hash}_set_marker(event.latLng.lat(), event.latLng.lng());\n"
			js += "		map_#{hash}_update_inputs(event.latLng.lat(), event.latLng.lng());\n"
			js += "	});\n"
			js += "	$('#map_#{hash} input.latitude').on('change', map_#{hash}_update_map);\n"
			js += "	$('#map_#{hash} input.longitude').on('change', map_#{hash}_update_map);\n"
			js += "	map_#{hash}_update_map();\n"
			js += "}\n"

			js += "function map_#{hash}_repair()\n"
			js += "{\n"
			js += "	google.maps.event.trigger(map_#{hash}, 'resize');\n"
			js += "	map_#{hash}_update_map();\n"
			js += "}\n"
			
			js += "$(document).ready(map_#{hash}_ready);\n"
			js += "$(document).on('page:load', map_#{hash}_ready);\n"

			result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
			result += @template.javascript_tag(js)
			
			# Container
			result += "<div id=\"map_#{hash}\" class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Text inputs
			result += "<div class=\"field-item\">"
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][latitude]", value_latitude, class: "text input normal latitude", placeholder: label_latitude)
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][longitude]", value_longitude, class: "text input normal longitude", placeholder: label_longitude)
			result += "</div>"

			# Mapbox (canvas)
			result += "<div class=\"field-item\">"
			result += "<div class=\"mapbox\"></div>"
			result += "</div>"

			# Container end
			result += "</div>"

			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

	end
end