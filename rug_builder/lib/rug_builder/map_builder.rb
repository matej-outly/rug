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
		# Render marker
		#
		def marker(name, latitude, longitude)
			return "rug_map_#{@hash}.addMarker('#{name.to_s}', #{latitude}, #{longitude});".html_safe
		end

		#
		# Render marker label
		#
		def marker_label(name, content)
			return "rug_map_#{@hash}.addMarkerLabel('#{name.to_s}', '#{content}');".html_safe
		end

		#
		# Render polygon
		#
		def polygon(name, points)
			return "rug_map_#{@hash}.addPolygon('#{name.to_s}', #{points.to_json});".html_safe
		end

		#
		# Render polygon label
		#
		def polygon_label(name, content)
			return "rug_map_#{@hash}.addPolygonLabel('#{name.to_s}', '#{content}');".html_safe
		end

	protected

		def js_library
			js = ""

			js += "function RugMap(hash, options)\n"
			js += "{\n"
			js += "	this.DEFAULT_LATITUDE = 50.0596696; /* Prague */\n"
			js += "	this.DEFAULT_LONGITUDE = 14.4656239;\n"
			js += "	this.DEFAULT_ZOOM = 9;\n"
			js += "	this.map = null;\n"
			js += "	this.markers = {};\n"
			js += "	this.marker_labels = {};\n"
			js += "	this.polygons = {};\n"
			js += "	this.polygon_labels = {};\n"
			js += "	this.hash = hash;\n"
			js += "	this.options = (typeof options !== 'undefined' ? options : {});\n"
			js += "}\n"
			js += "RugMap.prototype = {\n"
			js += "	constructor: RugMap,\n"
			js += "	addMarker: function(name, latitude, longitude)\n"
			js += "	{\n"
			js += "		var marker = new google.maps.Marker({\n"
			js += "			map: this.map,\n"
			js += "			position: {lat: latitude, lng: longitude}\n"
			js += "		});\n"
			js += "		this.markers[name] = marker;\n"
			js += "		return marker;\n"
			js += "	},\n"
			js += "	addMarkerLabel: function(name, content) \n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		var marker_label = null;\n"
			js += "		if (this.markers.hasOwnProperty(name)) {\n"
			js += "			marker_label = new google.maps.InfoWindow({ content: content });\n"
			js += "			this.markers[name].addListener('click', function(event) {\n"
			js += "				marker_label.open(_this.map, _this.markers[name]);\n"
			js += "			});\n"
			js += "			this.marker_labels[name] = marker_label;\n"
			js += "		}\n"
			js += "		return marker_label;\n"
			js += "	},\n"
			js += "	addPolygon: function(name, points) \n"
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
			js += "		this.polygons[name] = polygon;\n"
			js += "		return polygon;\n"
			js += "	},\n"
			js += "	addPolygonLabel: function(name, content) \n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		var polygon_label = null;\n"
			js += "		if (this.polygons.hasOwnProperty(name)) {\n"
			js += "			polygon_label = new google.maps.InfoWindow({ content: content });\n"
			js += "			this.polygons[name].addListener('click', function(event) {\n"
			js += "				polygon_label.setPosition(event.latLng);\n"
			js += "				polygon_label.open(_this.map);\n"
			js += "			});\n"
			js += "			this.polygon_labels[name] = polygon_label;\n"
			js += "		}\n"
			js += "		return polygon_label;\n"
			js += "	},\n"
			js += "	ready: function()\n"
			js += "	{\n"
			js += "		var _this = this;\n"
			js += "		var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);\n"
			js += "		var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);\n"
			js += "		var zoom = (this.options.zoom ? this.options.zoom : this.DEFAULT_ZOOM);\n"
			js += "		var map_canvas = $('#map_' + this.hash + ' .mapbox').get(0);\n"
			js += "		var map_position = new google.maps.LatLng(latitude, longitude);\n"
			js += "		var map_options = {\n"
			js += "			center: map_position,\n"
			js += "			zoom: zoom,\n"
			js += "			mapTypeId: google.maps.MapTypeId.ROADMAP,\n"
			js += "		}\n"
			js += "		this.map = new google.maps.Map(map_canvas, map_options);\n"
			js += "	},\n"
			js += "	repair: function()\n"
			js += "	{\n"
			js += "		google.maps.event.trigger(this.map, 'resize');\n"
			js += "		var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);\n"
			js += "		var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);\n"
			js += "		this.map.setCenter({lat: latitude, lng: longitude});\n"
			js += "	}\n"
			js += "}\n"

			return js
		end

		def js_application(&block)
			js = ""

			js += "var rug_map_#{@hash} = null;\n"
			js += "$(document).ready(function() {\n"
			js += "	rug_map_#{@hash} = new RugMap('#{@hash}', {\n"
			js += "		latitude: #{@options[:latitude]},\n" if @options[:latitude]
			js += "		longitude: #{@options[:longitude]},\n" if @options[:longitude]
			js += "		zoom: #{@options[:zoom]}\n" if @options[:zoom]
			js += "	});\n"
			js += "	rug_map_#{@hash}.ready();\n"
			js += @template.capture(self, &block).to_s
			js += "});\n"

			return js
		end

	end
end