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
			result += "<div id=\"map_location_#{hash}\" class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
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

			# Part labels
			label_street = (options[:label_street] ? options[:label_street] : I18n.t("general.attribute.address.street"))
			label_number = (options[:label_number] ? options[:label_number] : I18n.t("general.attribute.address.number"))
			label_city = (options[:label_city] ? options[:label_city] : I18n.t("general.attribute.address.city"))
			
			# Part values
			value = object.send(name)
			value_latitude = value && value[:latitude] ? value[:latitude] : nil
			value_longitude = value && value[:longitude] ? value[:longitude] : nil
			value_address = value && value[:address] ? value[:address] : nil
			
			# Java Script
			js = ""
			
			js += "function RugFormAddressLocation(hash, options)\n"
			js += "{\n"
			js += "	this.hash = hash;\n"
			js += "	this.options = (typeof options !== 'undefined' ? options : {});\n"
			js += "	this.geocoder = null;\n"
			js += "	this.lock = false; /* Lock if geocode in progress */\n"
			js += "	this.dirty = false; /* True if user selected address from suggestions */\n"
			js += "	this.form = null;\n"
			js += "	this.latitude_input = null;\n"
			js += "	this.longitude_input = null;\n"
			js += "	this.address_input = null;\n"
			js += "	this.street_input = null;\n"
			js += "	this.number_input = null;\n"
			js += "	this.city_input = null;\n"
			js += "}\n"
			js += "RugFormAddressLocation.prototype = {\n"
			js += "	constructor: RugFormAddressLocation,\n"
			js += "	parseAddress: function(address)\n"
			js += "	{\n"
			js += "		var country = null;\n"
			js += "		var city = null;\n"
			js += "		var street = null;\n"
			js += "		var number = null;\n"
			js += "		var address_parts = address.split(',').map(function(i) { return i.trim(' ') });\n"
			js += "		if (address_parts.length >= 1) {\n"
			js += "			country = address_parts.pop();\n"
			js += "		}\n"
			js += "		if (address_parts.length >= 1) {\n"
			js += "			city = address_parts.pop();\n"
			js += "		}\n"
			js += "		if (address_parts.length >= 1) {\n"
			js += "			street = address_parts.join(', ');\n"
			js += "			street_parts = street.split(' ');\n"
			js += "			for (var idx = street_parts.length-1; idx >= 0; idx--) {\n"
			js += "				if (/\\d/.test(street_parts[idx][0])) {\n"
			js += "					number = street_parts[idx];\n"
			js += "					if (number[number.length-1] == ',') {\n"
			js += "						if (idx > 0) {\n"
			js += "							street_parts[idx-1] += ',';\n"
			js += "						}\n"
			js += "						number = number.slice(0, -1);\n"
			js += "					}\n"
			js += "					street_parts.splice(idx, 1);\n"
			js += "				}\n"
			js += "			}\n"
			js += "			street = street_parts.join(' ');\n"
			js += "		}\n"
			js += "		return [country, city, street, number];\n"
			js += "	},\n"
			js += "	partsToAddress: function()\n"
			js += "	{\n"
			js += "		var street_and_number = [this.street_input.val(), this.number_input.val()].filter(function(i) { return i != '' }).join(' ');\n"
			js += "		var address = [street_and_number, this.city_input.val()].filter(function(i) { return i != '' }).join(', ');\n"
			js += "		this.address_input.val(address);\n"
			js += "	},\n"
			js += "	addressToParts: function()\n"
			js += "	{\n"
			js += "		var parsed_address = this.parseAddress(this.address_input.val());\n"
			js += "		this.street_input.val(parsed_address[2]);\n"
			js += "		this.number_input.val(parsed_address[3]);\n"
			js += "		this.city_input.val([parsed_address[1], parsed_address[0]].filter(function(i) { return i != null }).join(', '));\n"
			js += "	},\n"
			js += "	addressToLocation: function(callback)\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		var address = this.address_input.val();\n"
			js += "		if (address) {\n"
			js += "			this.geocode(address, function(latitude, longitude) {\n"
			js += "				_this.latitude_input.val(latitude);\n"
			js += "				_this.longitude_input.val(longitude);\n"
			js += "				if (typeof callback === 'function') callback();\n"
			js += "			});\n"
			js += "		} else {\n"
			js += "			this.latitude_input.val(null);\n"
			js += "			this.longitude_input.val(null);\n"
			js += "			if (typeof callback === 'function') callback();\n"
			js += "		}\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	locationToAddress: function(callback)\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		var latitude = parseFloat(this.latitude_input.val());\n"
			js += "		var longitude = parseFloat(this.longitude_input.val());\n"
			js += "		if (latitude && longitude) {\n"
			js += "			this.reverseGeocode(latitude, longitude, function(address) {\n"
			js += "				_this.address_input.val(address);\n"
			js += "				if (typeof callback === 'function') callback();\n"
			js += "			});\n"
			js += "		} else {\n"
			js += "			this.address_input.val(null);\n"
			js += "			if (typeof callback === 'function') callback();\n"
			js += "		}\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	suggest: function(address, callback) {\n"
			js += "		this.geocoder.geocode({\n"
			js += "			'address': address, \n"
			js += "			'componentRestrictions': {'country': '#{options[:restrict_country]}'}\n" if options[:restrict_country]
			js += "		}, function(results, status) {\n"
			js += "			if (status === google.maps.GeocoderStatus.OK) {\n"
			js += "				if (typeof callback === 'function') callback(results);\n"
			js += "			} else {\n"
			js += "				console.log('Geocode not successful with status: ' + status);\n"
			js += "				if (typeof callback === 'function') callback(null);\n"
			js += "			}\n"
			js += "		});\n"
			js += "	},\n"
			js += "	geocode: function(address, callback) {\n"
			js += "		this.geocoder.geocode({\n"
			js += "			'address': address,\n"
			js += "			'componentRestrictions': {'country': '#{options[:restrict_country]}'}\n" if options[:restrict_country]
			js += "		}, function(results, status) {\n"
			js += "			if (status === google.maps.GeocoderStatus.OK) {\n"
			js += "				if (typeof callback === 'function') callback(results[0].geometry.location.lat(), results[0].geometry.location.lng());\n"
			js += "			} else {\n"
			js += "				console.log('Geocode not successful with status: ' + status);\n"
			js += "				if (typeof callback === 'function') callback(null);\n"
			js += "			}\n"
			js += "		});\n"
			js += "	},\n"
			js += "	reverseGeocode: function(latitude, longitude, callback) {\n"
			js += "		this.geocoder.geocode({'location': {lat: latitude, lng: longitude}}, function(results, status) {\n"
			js += "			if (status === google.maps.GeocoderStatus.OK) {\n"
			js += "				if (results[0]) {\n"
			js += "					if (typeof callback === 'function') callback(results[0].formatted_address);\n"
			js += "				} else {\n"
			js += "					if (typeof callback === 'function') callback(null);\n"
			js += "				}\n"
			js += "			} else {\n"
			js += "				console.log('Reverse geocode not successful with status: ' + status);\n"
			js += "				if (typeof callback === 'function') callback(null);\n"
			js += "			}\n"
			js += "		});\n"
			js += "	},\n"
			js += "	onSuggest: function(term, response) {\n"
			js += "		var _this = this;\n"
			js += "		if (this.lock == false) {\n"
			js += "			this.lock = true;\n"
			js += "			this.suggest(this.address_input.val(), function(results) {\n"
			js += "				if (results) {\n"
			js += "					suggestions = [];\n"
			js += "					for (i = 0; i < results.length; i++) { \n"
			js += "						suggestions.push(results[i].formatted_address);\n"
			js += "					}\n"
			js += "					response(suggestions);\n"
			js += "				}\n"
			js += "				_this.lock = false;\n"
			js += "			});\n"
			js += "		}\n"
			js += "	},\n"
			js += "	onSelected: function(address, callback)\n"
			js += "	{\n"
			js += "		this.address_input.val(address);\n"
			js += "		this.addressToParts();\n"
			js += "		this.addressToLocation(callback);\n"
			js += "		this.dirty = false;	\n"
			js += "	},\n"
			js += "	onKeypress: function()\n"
			js += "	{\n"
			js += "		this.partsToAddress();\n"
			js += "		this.dirty = true;	\n"
			js += "	},\n"
			js += "	onSubmit: function(callback)\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		if (this.dirty) {\n"
			js += "			this.suggest(this.address_input.val(), function(results) {\n"
			js += "				if (results) {\n"
			js += "					var message = 'Máte na mysli adresu <strong>' + results[0].formatted_address + '</strong>? Pokud ne, klikněte na tlačítko <strong>NE</strong> a adresu lépe specifikujte (doplňte město či číslo popisné).';\n"
			js += "					alertify.confirm(message, function (confirmed) {\n"
			js += "						if (confirmed) {\n"
			js += "							_this.onSelected(results[0].formatted_address, callback);\n"
			js += "						} else {\n"
			js += "							console.log('Not confirmed');\n"
			js += "						}\n"
			js += "					});\n"
			js += "				} else {\n"
			js += "					var message = 'Je nám to velice líto, ale vyplněnou adresu jsme nerozpoznali. Chcete adresu lépe specifikovat? Pokud ano, klikněte na tlačítko <strong>ANO</strong> a doplňte více informací (např. město či číslo popisné). Pokud chcete adresu smazat a formulář odeslat, klikněte na <strong>NE</strong>.';\n"
			js += "					alertify.confirm(message, function (confirmed) {\n"
			js += "						if (confirmed) {\n"
			js += "							console.log('Confirmed');\n"
			js += "						} else {\n"
			js += "							_this.onSelected(null, callback);\n"
			js += "						}\n"
			js += "					});\n"
			js += "				}\n"
			js += "			});\n"
			js += "		} else {\n"
			js += "			if (typeof callback === 'function') callback();\n"
			js += "		}\n"
			js += "	},\n"
			js += "	ready: function()\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		this.form = $('#address_location_' + this.hash).closest('form');\n"
			js += "		this.latitude_input = $('#address_location_' + this.hash + ' input.latitude');\n"
			js += "		this.longitude_input = $('#address_location_' + this.hash + ' input.longitude');\n"
			js += "		this.address_input = $('#address_location_' + this.hash + ' input.address');\n"
			js += "		this.street_input = $('#address_location_' + this.hash + ' input.street');\n"
			js += "		this.number_input = $('#address_location_' + this.hash + ' input.number');\n"
			js += "		this.city_input = $('#address_location_' + this.hash + ' input.city');\n"
			js += "		this.geocoder = new google.maps.Geocoder();\n"
			js += "		alertify.set({ \n"
			js += "			labels: {\n"
			js += "				ok: '#{I18n.t("general.bool_yes").upcase_first}',\n"
			js += "				cancel: '#{I18n.t("general.bool_no").upcase_first}'\n"
			js += "			}\n"
			js += "		});\n"
			js += "		this.number_input.autoComplete({\n"
			js += "			minChars: 1,\n"
			js += "			source: function(term, response) { _this.onSuggest(term, response) },\n"
			js += "			onSelect: function(e, term, item) { _this.onSelected(term); }\n"
			js += "		});\n"
			js += "		this.number_input.keyup(function() { _this.onKeypress(); });\n"
			js += "		this.street_input.autoComplete({\n"
			js += "			minChars: 3,\n"
			js += "			source: function(term, response) { _this.onSuggest(term, response) },\n"
			js += "			onSelect: function(e, term, item) { _this.onSelected(term); }\n"
			js += "		});\n"
			js += "		this.street_input.keyup(function() { _this.onKeypress(); });\n"
			js += "		this.city_input.autoComplete({\n"
			js += "			minChars: 3,\n"
			js += "			source: function(term, response) { _this.onSuggest(term, response) },\n"
			js += "			onSelect: function(e, term, item) { _this.onSelected(term); }\n"
			js += "		});\n"
			js += "		this.city_input.keyup(function() { _this.onKeypress(); });\n"
			js += "		this.form.on('submit', function(event) {\n"
			js += "			_this.onSubmit(function () { _this.form.off('submit'); _this.form.submit(); });\n"
			js += "			event.preventDefault();\n"
			js += "		});\n"
			js += "		this.addressToParts();\n"
			js += "	}\n"
			js += "}\n"

			js += "var rug_form_address_location_#{hash} = null;\n"
			js += "$(document).ready(function() {\n"
			js += "	rug_form_address_location_#{hash} = new RugFormAddressLocation('#{hash}', {\n"
			js += "	});\n"
			js += "	rug_form_address_location_#{hash}.ready();\n"
			js += "});\n"

			result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
			result += @template.javascript_tag(js)
			
			# Container
			result += "<div id=\"address_location_#{hash}\" class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Address parts inputs
			result += "<div class=\"field-item\">"
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][street]", "", class: "text input street normal", placeholder: label_street)
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][number]", "", class: "text input number normal", placeholder: label_number)
			result += "</div>"

			result += "<div class=\"field-item\">"
			result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][city]", "", class: "text input city", placeholder: label_city)
			result += "</div>"

			# Address input
			result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][address]", value_address, class: "text input address")
			
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