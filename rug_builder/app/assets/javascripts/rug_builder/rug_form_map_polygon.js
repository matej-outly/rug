/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Map Polygon                                                      */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormMapPolygon(hash, options)
{
	this.DEFAULT_LATITUDE = 50.0596696; /* Prague */
	this.DEFAULT_LONGITUDE = 14.4656239;
	this.DEFAULT_ZOOM = 9;
	this.map = null;
	this.markers = [];
	this.polygon = null;
	this.hash = hash;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormMapPolygon.prototype = {
	constructor: RugFormMapPolygon,
	updateInput: function()
	{
		var value = null;
		if (this.markers.length > 0) {
			value = [];
			for (var i = 0; i < this.markers.length; i++) {
				var marker = this.markers[i];
				value.push([marker.getPosition().lat(),marker.getPosition().lng()]);
			}
			value = JSON.stringify(value);
		} else {
			value = '';
		}
		$('#map-polygon-' + this.hash + ' input').val(value);
		return true;
	},
	updateMap: function()
	{
		var value = $('#map-polygon-' + this.hash + ' input').val();
		value = JSON.parse(value);
		this.clearMarkers();
		if (value instanceof Array) {
			for (var i = 0; i < value.length; i++) {
				if (value[i] instanceof Array && value[i].length == 2) {
					this.addMarker(parseFloat(value[i][0]), parseFloat(value[i][1]));
				} else {
					this.clearMarkers();
					return false;
				}
			}
		}
		this.redrawPolygon();
		return true;
	},
	addMarker: function(latitude, longitude)
	{
		var _this = this;
		var marker = new google.maps.Marker({
			map: this.map,
			draggable: true,
			position: {lat: latitude, lng: longitude}
		});
		marker.addListener('dragend', function(event) {
			_this.redrawPolygon();
			_this.updateInput();
		});
		marker.addListener('click', function() {
			_this.removeMarker(marker);
			_this.redrawPolygon();
			_this.updateInput();
		});
		this.markers.push(marker);
		this.map.panTo({lat: latitude, lng: longitude});
	},
	removeMarker: function(marker)
	{
		marker.setMap(null);
		for (var i = 0; i < this.markers.length; i++) {
			if (marker == this.markers[i]) {
				this.markers.splice(i, 1);
				break;
			}
		}
	},
	clearMarkers: function()
	{
		for (var i = 0; i < this.markers.length; i++) {
			var marker = this.markers[i];
			marker.setMap(null);
		}
		this.markers = [];
	},
	redrawPolygon: function() 
	{
		if (this.polygon != null) {
			this.polygon.setMap(null);
			this.polygon = null;
		}
		var points = [];
		for (var i = 0; i < this.markers.length; i++) {
			var marker = this.markers[i];
			points.push({lat: marker.getPosition().lat(), lng: marker.getPosition().lng()});
		}
		this.polygon = new google.maps.Polygon({
			paths: points,
			strokeColor: '#FF0000',
			strokeOpacity: 0.8,
			strokeWeight: 2,
			fillColor: '#FF0000',
			fillOpacity: 0.2
		});
		this.polygon.setMap(this.map);
	},
	ready: function()
	{
		var _this = this;
		var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);
		var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);
		var zoom = (this.options.zoom ? this.options.zoom : this.DEFAULT_ZOOM);
		var mapCanvas = $('#map-polygon-' + this.hash + ' .mapbox').get(0);
		var mapPosition = new google.maps.LatLng(latitude, longitude);
		var mapOptions = {
			center: mapPosition,
			zoom: zoom,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
		}
		this.map = new google.maps.Map(mapCanvas, mapOptions);
		google.maps.event.addListener(this.map, 'click', function(event) {
			_this.addMarker(event.latLng.lat(), event.latLng.lng());
			_this.redrawPolygon();
			_this.updateInput();
		});
		this.updateMap();

		// Repair map on tab change
		$('a[data-toggle="tab"]').on('shown.bs.tab', this.repair.bind(this));
	},
	repair: function()
	{
		google.maps.event.trigger(this.map, 'resize');
		this.updateMap();
	}
}