# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug map builder
# *
# * Author: Matěj Outlý
# * Date  : 24. 11. 2015
# *
# *****************************************************************************

module RugBuilder
	class MapBuilder

		#
		# Constructor
		#
		def initialize(template)
			@template = template
		end

		#
		# Main render method
		#
		def render(name, options = {}, &block)
			
			# Unique hash
			@hash = Digest::SHA1.hexdigest(name.to_s)

			# Options
			@options = options

			# Wrapper
			result = ""
			result += "<div id=\"map_#{@hash}\" class=\"map\">"

			# Mapbox (canvas)
			result += "<div class=\"mapbox\"></div>"
			
			# Google API
			result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
			
			# Map library
			result += @template.javascript_tag(js_library)

			# Map application
			result += @template.javascript_tag(js_application(&block))

			# Wrapper
			result += "</div>"

			return result.html_safe
		end

		#
		# Render location
		#
		def location(name, latitude, longitude)
			return "rug_map_#{@hash}.addMarker(#{latitude}, #{longitude})"
		end

		#
		# Render polygon
		#
		def polygon(name, points)
			return "rug_map_#{@hash}.addPolygon(#{points.to_json})"
		end

	protected

		def js_library
			js = ""

			js += "function RugMap(hash, options)\n"
			js += "{\n"
			js += "	this.map = null;\n"
			js += "	this.markers = [];\n"
			js += "	this.polygons = [];\n"
			js += "	this.hash = hash;\n"
			js += "	this.options = (typeof options !== 'undefined' ? options : {});\n"
			js += "}\n"
			js += "RugMap.prototype = {\n"
			js += "	constructor: RugMap,\n"
			js += "	addMarker: function(latitude, longitude)\n"
			js += "	{\n"
			js += "		var marker = new google.maps.Marker({\n"
			js += "			map: this.map,\n"
			js += "			position: {lat: latitude, lng: longitude}\n"
			js += "		});\n"
			js += "		this.markers.push(marker);\n"
			js += "		return marker;\n"
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
			js += "		return true;\n"
			js += "	},\n"
			js += "	clearMarkers: function()\n"
			js += "	{\n"
			js += "		for (var i = 0; i < this.markers.length; i++) {\n"
			js += "			var marker = this.markers[i];\n"
			js += "			marker.setMap(null);\n"
			js += "		}\n"
			js += "		this.markers = [];\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	addPolygon: function(points) \n"
			js += "	{\n"
			js += "		var points_to_draw = [];\n"
			js += "		if (points instanceof Array) {\n"
			js += "			for (var i = 0; i < points.length; i++) {\n"
			js += "				if (points[i] instanceof Array && points[i].length == 2) {\n"
			js += "					points_to_draw.push({lat: parseFloat(points[i][0]), lng: parseFloat(points[i][1])});\n"
			js += "				} else {\n"
			js += "					return null;\n"
			js += "				}\n"
			js += "			}\n"
			js += "		}\n"
			js += "		var polygon = new google.maps.Polygon({\n"
			js += "			paths: points_to_draw,\n"
			js += "			strokeColor: '#FF0000',\n"
			js += "			strokeOpacity: 0.8,\n"
			js += "			strokeWeight: 2,\n"
			js += "			fillColor: '#FF0000',\n"
			js += "			fillOpacity: 0.2\n"
			js += "		});\n"
			js += "		polygon.setMap(this.map);\n"
			js += "		this.polygons.push(polygon);\n"
			js += "		return polygon;\n"
			js += "	},\n"
			js += "	removePolygon: function(polygon)\n"
			js += "	{\n"
			js += "		polygon.setMap(null);\n"
			js += "		for (var i = 0; i < this.polygons.length; i++) {\n"
			js += "			if (polygon == this.polygons[i]) {\n"
			js += "				this.polygons.splice(i, 1);\n"
			js += "				break;\n"
			js += "			}\n"
			js += "		}\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	clearPolygons: function()\n"
			js += "	{\n"
			js += "		for (var i = 0; i < this.polygons.length; i++) {\n"
			js += "			var polygon = this.polygons[i];\n"
			js += "			polygon.setMap(null);\n"
			js += "		}\n"
			js += "		this.polygons = [];\n"
			js += "		return true;\n"
			js += "	},\n"
			js += "	clear: function()\n"
			js += "	{\n"
			js += "		this.clearMarkers();\n"
			js += "		this.clearPolygons();\n"
			js += "		return true;\n"
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
			js += "	},\n"
			js += "	repair: function()\n"
			js += "	{\n"
			js += "		google.maps.event.trigger(this.map, 'resize');\n"
			js += "	}\n"
			js += "}\n"

			return js
		end

		def js_application(&block)
			js = ""

			js += "var rug_map_#{@hash} = null;\n"
			js += "$(document).ready(function() {\n"
			js += "	rug_map_#{@hash} = new RugMap('#{@hash}', {\n"
			js += "		default_latitude: #{( @options[:default_latitude] ? @options[:default_latitude] : 50.0596696)},\n"
			js += "		default_longitude: #{( @options[:default_longitude] ? @options[:default_longitude] : 14.4656239)},\n"
			js += "		default_zoom: #{( @options[:default_zoom] ? @options[:default_zoom] : 9)}\n"
			js += "	});\n"
			js += "	rug_map_#{@hash}.ready();\n"
			js += @template.capture(self, &block).to_s
			js += "});\n"

			return js
		end

		def controller_path
			return @template.controller.class.name.to_snake[0..-12]
		end

	end
end