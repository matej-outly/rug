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
			
			# Java Script TODO: refactor to OOP
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

		def map_rectangle_row(name, options = {})
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
			label_top = (options[:label_top] ? options[:label_top] : I18n.t("general.attribute.georectangle.top"))
			label_bottom = (options[:label_bottom] ? options[:label_bottom] : I18n.t("general.attribute.georectangle.bottom"))
			label_left = (options[:label_left] ? options[:label_left] : I18n.t("general.attribute.georectangle.left"))
			label_right = (options[:label_right] ? options[:label_right] : I18n.t("general.attribute.georectangle.right"))
			
			# Part values
			value = object.send(name)
			value_top = value && value[:top] ? value[:top] : nil
			value_bottom = value && value[:bottom] ? value[:bottom] : nil
			value_left = value && value[:left] ? value[:left] : nil
			value_right = value && value[:right] ? value[:right] : nil
						
			# Container
			result += "<div id=\"map_#{hash}\" class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Text inputs (first row)
			result += "<div class=\"field-item\">"
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][top]", value_top, class: "text input normal top", placeholder: label_top)
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][bottom]", value_bottom, class: "text input normal bottom", placeholder: label_bottom)
			result += "</div>"

			# Text inputs (second row)
			result += "<div class=\"field-item\">"
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][left]", value_left, class: "text input normal left", placeholder: label_left)
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][right]", value_right, class: "text input normal right", placeholder: label_right)
			result += "</div>"

			# Mapbox (canvas)
			#result += "<div class=\"field-item\">"
			#result += "<div class=\"mapbox\"></div>"
			#result += "</div>"

			# Container end
			result += "</div>"

			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

		def map_polygon_row(name, options = {})
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

			# Part values
			value = object.send(name)
			
			# Java Script
			js = ""

			js += "function FormMapPolygon(hash, options)\n"
			js += "{\n"
			js += "	this.map = null;\n"
			js += "	this.markers = [];\n"
			js += "	this.polygon = null;\n"
			js += "	this.hash = hash;\n"
			js += "	this.options = (typeof options !== 'undefined' ? options : {});\n"
			js += "}\n"
			js += "FormMapPolygon.prototype = {\n"
			js += "	constructor: FormMapPolygon,\n"
			js += "	updateInput: function()\n"
			js += "	{\n"
			js += "		var value = null;\n"
			js += "		if (this.markers.length > 0) {\n"
			js += "			value = [];\n"
			js += "			for (var i = 0; i < this.markers.length; i++) {\n"
			js += "				var marker = this.markers[i];\n"
			js += "				value.push([marker.getPosition().lat(),marker.getPosition().lng()]);\n"
			js += "			}\n"
			js += "			value = JSON.stringify(value);\n"
			js += "		} else {\n"
			js += "			value = '';\n"
			js += "		}\n"
			js += "		$('#map_' + this.hash + ' input').val(value);\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	updateMap: function()\n"
			js += "	{\n"
			js += "		var value = $('#map_' + this.hash + ' input').val();\n"
			js += "		value = JSON.parse(value);\n"
			js += "		this.clearMarkers();\n"
			js += "		if (value instanceof Array) {\n"
			js += "			for (var i = 0; i < value.length; i++) {\n"
			js += "				if (value[i] instanceof Array && value[i].length == 2) {\n"
			js += "					this.addMarker(parseFloat(value[i][0]), parseFloat(value[i][1]));\n"
			js += "				} else {\n"
			js += "					this.clearMarkers();\n"
			js += "					return false;\n"
			js += "				}\n"
			js += "			}\n"
			js += "		}\n"
			js += "		this.redrawPolygon();\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	addMarker: function(latitude, longitude)\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		var marker = new google.maps.Marker({\n"
			js += "			map: this.map,\n"
			js += "			draggable: true,\n"
			js += "			position: {lat: latitude, lng: longitude}\n"
			js += "		});\n"
			js += "		marker.addListener('dragend', function(event) {\n"
			js += "			_this.redrawPolygon();\n"
			js += "			_this.updateInput();\n"
			js += "		});\n"
			js += "		marker.addListener('click', function() {\n"
			js += "			_this.removeMarker(marker);\n"
			js += "			_this.redrawPolygon();\n"
			js += "			_this.updateInput();\n"
			js += "		});\n"
			js += "		this.markers.push(marker);\n"
			js += "		this.map.panTo({lat: latitude, lng: longitude});\n"
			js += "	},\n"
			js += "	removeMarker: function(marker)\n"
			js += "	{\n"
			js += "		marker.setMap(null);\n"
			js += "		for (var i = 0; i < this.markers.length; i++) {\n"
			js += "			if (marker == this.markers[i]) {\n"
			js += "				this.markers.splice(i, 1);\n"
			js += "				break;\n"
			js += "			}\n"
			js += "		}\n"
			js += "	},\n"
			js += "	clearMarkers: function()\n"
			js += "	{\n"
			js += "		for (var i = 0; i < this.markers.length; i++) {\n"
			js += "			var marker = this.markers[i];\n"
			js += "			marker.setMap(null);\n"
			js += "		}\n"
			js += "		this.markers = [];\n"
			js += "	},\n"
			js += "	redrawPolygon: function() \n"
			js += "	{\n"
			js += "		if (this.polygon != null) {\n"
			js += "			this.polygon.setMap(null);\n"
			js += "			this.polygon = null;\n"
			js += "		}\n"
			js += "		var points = [];\n"
			js += "		for (var i = 0; i < this.markers.length; i++) {\n"
			js += "			var marker = this.markers[i];\n"
			js += "			points.push({lat: marker.getPosition().lat(), lng: marker.getPosition().lng()});\n"
			js += "		}\n"
			js += "		this.polygon = new google.maps.Polygon({\n"
			js += "			paths: points,\n"
			js += "			strokeColor: '#FF0000',\n"
			js += "			strokeOpacity: 0.8,\n"
			js += "			strokeWeight: 2,\n"
			js += "			fillColor: '#FF0000',\n"
			js += "			fillOpacity: 0.2\n"
			js += "		});\n"
			js += "		this.polygon.setMap(this.map);\n"
			js += "	},\n"
			js += "	ready: function()\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		var default_latitude = (this.options.default_latitude ? this.options.default_latitude : 50.0596696); /* Prague */\n"
			js += "		var default_longitude = (this.options.default_longitude ? this.options.default_longitude : 14.4656239);\n"
			js += "		var default_zoom = (this.options.default_zoom ? this.options.default_zoom : 9);\n"
			js += "		var map_canvas = $('#map_' + this.hash + ' .mapbox').get(0);\n"
			js += "		var map_position = new google.maps.LatLng(default_latitude, default_longitude);\n"
			js += "		var map_options = {\n"
			js += "			center: map_position,\n"
			js += "			zoom: default_zoom,\n"
			js += "			mapTypeId: google.maps.MapTypeId.ROADMAP,\n"
			js += "		}\n"
			js += "		this.map = new google.maps.Map(map_canvas, map_options);\n"
			js += "		google.maps.event.addListener(this.map, 'click', function(event) {\n"
			js += "			_this.addMarker(event.latLng.lat(), event.latLng.lng());\n"
			js += "			_this.redrawPolygon();\n"
			js += "			_this.updateInput();\n"
			js += "		});\n"
			js += "		this.updateMap();\n"
			js += "	},\n"
			js += "	repair: function()\n"
			js += "	{\n"
			js += "		google.maps.event.trigger(this.map, 'resize');\n"
			js += "		this.updateMap();\n"
			js += "	}\n"
			js += "}\n"

			js += "var form_map_polygon_#{hash} = null;\n"
			js += "$(document).ready(function() {\n"
			js += "	form_map_polygon_#{hash} = new FormMapPolygon('#{hash}', {\n"
			js += "		default_latitude: #{( options[:default_latitude] ? options[:default_latitude] : 50.0596696)},\n"
			js += "		default_longitude: #{( options[:default_longitude] ? options[:default_longitude] : 14.4656239)},\n"
			js += "		default_zoom: #{( options[:default_zoom] ? options[:default_zoom] : 9)}\n"
			js += "	});\n"
			js += "	form_map_polygon_#{hash}.ready();\n"
			js += "});\n"

			result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
			result += @template.javascript_tag(js)
			
			# Container
			result += "<div id=\"map_#{hash}\" class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Input
			result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value.to_json)

			# Mapbox (canvas)
			result += "<div class=\"mapbox\"></div>"

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