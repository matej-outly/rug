/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Map                                                                   */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 18. 5. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugMap(hash, options)
{
	this.DEFAULT_LATITUDE = 50.0596696; /* Prague */
	this.DEFAULT_LONGITUDE = 14.4656239;
	this.DEFAULT_ZOOM = 9;
	this.map = null;
	this.markers = {};
	this.marker_labels = {};
	this.polygons = {};
	this.polygon_labels = {};
	this.hash = hash;
	this.options = (typeof options !== 'undefined' ? options : {});
}
RugMap.prototype = {
	constructor: RugMap,
	addMarker: function(name, latitude, longitude)
	{
		var marker = new google.maps.Marker({
			map: this.map,
			position: {lat: latitude, lng: longitude}
		});
		this.markers[name] = marker;
		return marker;
	},
	addMarkerLabel: function(name, content) 
	{
		var _this = this;
		var marker_label = null;
		if (this.markers.hasOwnProperty(name)) {
			marker_label = new google.maps.InfoWindow({ content: content });
			this.markers[name].addListener('click', function(event) {
				marker_label.open(_this.map, _this.markers[name]);
			});
			this.marker_labels[name] = marker_label;
		}
		return marker_label;
	},
	addPolygon: function(name, points) 
	{
		var points_to_draw = [];
		if (points instanceof Array) {
			for (var i = 0; i < points.length; i++) {
				if (points[i] instanceof Array && points[i].length == 2) {
					points_to_draw.push({lat: parseFloat(points[i][0]), lng: parseFloat(points[i][1])});
				} else {
					return null;
				}
			}
		}
		var polygon = new google.maps.Polygon({
			paths: points_to_draw,
			strokeColor: '#FF0000',
			strokeOpacity: 0.8,
			strokeWeight: 2,
			fillColor: '#FF0000',
			fillOpacity: 0.2
		});
		polygon.setMap(this.map);
		this.polygons[name] = polygon;
		return polygon;
	},
	addPolygonLabel: function(name, content) 
	{
		var _this = this;
		var polygon_label = null;
		if (this.polygons.hasOwnProperty(name)) {
			polygon_label = new google.maps.InfoWindow({ content: content });
			this.polygons[name].addListener('click', function(event) {
				polygon_label.setPosition(event.latLng);
				polygon_label.open(_this.map);
			});
			this.polygon_labels[name] = polygon_label;
		}
		return polygon_label;
	},
	ready: function()
	{
		var _this = this;
		var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);
		var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);
		var zoom = (this.options.zoom ? this.options.zoom : this.DEFAULT_ZOOM);
		var map_canvas = $('#map_' + this.hash + ' .mapbox').get(0);
		var map_position = new google.maps.LatLng(latitude, longitude);
		var map_options = {
			center: map_position,
			zoom: zoom,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			scrollwheel: (this.options.scrollwheel != null ? this.options.scrollwheel : true),
		}
		this.map = new google.maps.Map(map_canvas, map_options);

		// Repair map on tab change
		$('a[data-toggle="tab"]').on('shown.bs.tab', this.repair.bind(this));
	},
	repair: function()
	{
		google.maps.event.trigger(this.map, 'resize');
		var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);
		var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);
		this.map.setCenter({lat: latitude, lng: longitude});
	}
}