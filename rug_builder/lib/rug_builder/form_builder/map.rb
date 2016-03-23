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
			
			# Field options
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input"

			# Java Script
			js = ""
			
			js += "function RugFormMapLocation(hash, options)\n"
			js += "{\n"
			js += "	this.DEFAULT_LATITUDE = 50.0596696; /* Prague */\n"
			js += "	this.DEFAULT_LONGITUDE = 14.4656239;\n"
			js += "	this.DEFAULT_ZOOM = 9;\n"
			js += "	this.map = null;\n"
			js += "	this.marker = null;\n"
			js += "	this.hash = hash;\n"
			js += "	this.options = (typeof options !== 'undefined' ? options : {});\n"
			js += "}\n"
			js += "RugFormMapLocation.prototype = {\n"
			js += "	constructor: RugFormMapLocation,\n"
			js += "	updateInputs: function()\n"
			js += "	{\n"
			js += "		if (this.marker != null) {\n"
			js += "			$('#map_location_' + this.hash + ' input.latitude').val(this.marker.getPosition().lat());\n"
			js += "			$('#map_location_' + this.hash + ' input.longitude').val(this.marker.getPosition().lng());\n"
			js += "		} else {\n"
			js += "			$('#map_location_' + this.hash + ' input.latitude').val(null);\n"
			js += "			$('#map_location_' + this.hash + ' input.longitude').val(null);\n"
			js += "		}\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	updateMap: function()\n"
			js += "	{\n"
			js += "		var latitude = parseFloat($('#map_location_' + this.hash + ' input.latitude').val());\n"
			js += "		var longitude = parseFloat($('#map_location_' + this.hash + ' input.longitude').val());\n"
			js += "		if (latitude && longitude) {\n"
			js += "			this.setMarker(latitude, longitude);\n"
			js += "		} else {\n"
			js += "			this.removeMarker();\n"
			js += "		}\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	setMarker: function(latitude, longitude)\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		if (this.marker == null) {\n"
			js += "			this.marker = new google.maps.Marker({\n"
			js += "				map: this.map,\n"
			js += "				draggable: true,\n"
			js += "				position: {lat: latitude, lng: longitude}\n"
			js += "			});\n"
			js += "			this.marker.addListener('dragend', function(event) {\n"
			js += "				_this.updateInputs();\n"
			js += "			});\n"
			js += "			this.marker.addListener('click', function() {\n"
			js += "				_this.removeMarker();\n"
			js += "				_this.updateInputs();\n"
			js += "			});\n"
			js += "		} else {\n"
			js += "			this.marker.setPosition({lat: latitude, lng: longitude});\n"
			js += "		}\n"
			js += "		this.map.panTo({lat: latitude, lng: longitude});\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	removeMarker: function()\n"
			js += "	{\n"
			js += "		if (this.marker != null) {\n"
			js += "			this.marker.setMap(null);\n"
			js += "			this.marker = null;\n"
			js += "		}\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	ready: function()\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);\n"
			js += "		var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);\n"
			js += "		var zoom = (this.options.zoom ? this.options.zoom : this.DEFAULT_ZOOM);\n"
			js += "		var map_canvas = $('#map_location_' + this.hash + ' .mapbox').get(0);\n"
			js += "		var map_position = new google.maps.LatLng(latitude, longitude);\n"
			js += "		var map_options = {\n"
			js += "			center: map_position,\n"
			js += "			zoom: zoom,\n"
			js += "			mapTypeId: google.maps.MapTypeId.ROADMAP,\n"
			js += "		}\n"
			js += "		this.map = new google.maps.Map(map_canvas, map_options);\n"
			js += "		google.maps.event.addListener(this.map, 'click', function(event) {\n"
			js += "			_this.setMarker(event.latLng.lat(), event.latLng.lng());\n"
			js += "			_this.updateInputs();\n"
			js += "		});\n"
			js += "		$('#map_location_' + this.hash + ' input.latitude').on('change', function() { _this.updateMap(); });\n"
			js += "		$('#map_location_' + this.hash + ' input.longitude').on('change', function() { _this.updateMap(); });\n"
			js += "		this.updateMap();\n"
			js += "	},\n"
			js += "	repair: function()\n"
			js += "	{\n"
			js += "		google.maps.event.trigger(this.map, 'resize');\n"
			js += "		this.updateMap();\n"
			js += "	}\n"
			js += "}\n"

			js += "var rug_form_map_location_#{hash} = null;\n"
			js += "$(document).ready(function() {\n"
			js += "	rug_form_map_location_#{hash} = new RugFormMapLocation('#{hash}', {\n"
			js += "		latitude: #{@options[:latitude]},\n" if @options[:latitude]
			js += "		longitude: #{@options[:longitude]},\n" if @options[:longitude]
			js += "		zoom: #{@options[:zoom]}\n" if @options[:zoom]
			js += "	});\n"
			js += "	rug_form_map_location_#{hash}.ready();\n"
			js += "});\n"

			result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
			result += @template.javascript_tag(js)
			
			# Container
			result += "<div id=\"map_location_#{hash}\" class=\"prepend field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Text inputs
			result += "<div class=\"row\">"
			result += "<div class=\"six columns field-item\">" 
			result += "<span class=\"adjoined\">#{label_latitude.upcase_first}</span>" if options[:join] != false
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][latitude]", value_latitude, class: klass.dup.concat(["latitude", (options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_latitude.upcase_first : nil))
			result += "</div>"

			result += "<div class=\"six columns field-item\">"
			result += "<span class=\"adjoined\">#{label_longitude.upcase_first}</span>" if options[:join] != false
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][longitude]", value_longitude, class: klass.dup.concat(["longitude", (options[:join] != false ? "normal" : "")]).join(" "), placeholder: (options[:placeholder] == true ? label_longitude.upcase_first : nil))
			result += "</div>"
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

			js += "function RugFormMapPolygon(hash, options)\n"
			js += "{\n"
			js += "	this.DEFAULT_LATITUDE = 50.0596696; /* Prague */\n"
			js += "	this.DEFAULT_LONGITUDE = 14.4656239;\n"
			js += "	this.DEFAULT_ZOOM = 9;\n"
			js += "	this.map = null;\n"
			js += "	this.markers = [];\n"
			js += "	this.polygon = null;\n"
			js += "	this.hash = hash;\n"
			js += "	this.options = (typeof options !== 'undefined' ? options : {});\n"
			js += "}\n"
			js += "RugFormMapPolygon.prototype = {\n"
			js += "	constructor: RugFormMapPolygon,\n"
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
			js += "		$('#map_polygon_' + this.hash + ' input').val(value);\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	updateMap: function()\n"
			js += "	{\n"
			js += "		var value = $('#map_polygon_' + this.hash + ' input').val();\n"
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
			js += "		var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);\n"
			js += "		var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);\n"
			js += "		var zoom = (this.options.zoom ? this.options.zoom : this.DEFAULT_ZOOM);\n"
			js += "		var map_canvas = $('#map_polygon_' + this.hash + ' .mapbox').get(0);\n"
			js += "		var map_position = new google.maps.LatLng(latitude, longitude);\n"
			js += "		var map_options = {\n"
			js += "			center: map_position,\n"
			js += "			zoom: zoom,\n"
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

			js += "var rug_form_map_polygon_#{hash} = null;\n"
			js += "$(document).ready(function() {\n"
			js += "	rug_form_map_polygon_#{hash} = new RugFormMapPolygon('#{hash}', {\n"
			js += "		latitude: #{@options[:latitude]},\n" if @options[:latitude]
			js += "		longitude: #{@options[:longitude]},\n" if @options[:longitude]
			js += "		zoom: #{@options[:zoom]}\n" if @options[:zoom]
			js += "	});\n"
			js += "	rug_form_map_polygon_#{hash}.ready();\n"
			js += "});\n"

			result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
			result += @template.javascript_tag(js)
			
			# Container
			result += "<div id=\"map_polygon_#{hash}\" class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
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

		def address_location_row(name, options = {})
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
			value_latitude = value && value[:latitude] ? value[:latitude] : nil
			value_longitude = value && value[:longitude] ? value[:longitude] : nil
			value_level = value && value[:level] ? value[:level] : nil
			value_address = value && value[:address] ? value[:address] : nil
			
			# Address field options
			field_options = {}
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input address"
			field_options[:class] = klass.join(" ")
			field_options[:placeholder] = options[:placeholder] if !options[:placeholder].nil?

			# Java Script
			#js = ""
			
			# TODO sofar must be done in application JS

			#result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
			#result += @template.javascript_tag(js)
			
			# Container
			result += "<div id=\"address_location_#{hash}\" class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Address input
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][address]", value_address, field_options)
			
			# Level input
			result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][level]", value_level, class: "level")
			
			# Location inputs
			result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][latitude]", value_latitude, class: "latitude")
			result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][longitude]", value_longitude, class: "longitude")
			
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