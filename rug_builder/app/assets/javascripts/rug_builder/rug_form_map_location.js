/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Map Location                                                     */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormMapLocation(hash, options)
{
	this.DEFAULT_LATITUDE = 50.0596696; /* Prague */
	this.DEFAULT_LONGITUDE = 14.4656239;
	this.DEFAULT_ZOOM = 9;
	this.map = null;
	this.marker = null;
	this.hash = hash;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormMapLocation.prototype = {
	constructor: RugFormMapLocation,
	updateInputs: function()
	{
		if (this.marker != null) {
			$('#map_location_' + this.hash + ' input.latitude').val(this.marker.getPosition().lat());
			$('#map_location_' + this.hash + ' input.longitude').val(this.marker.getPosition().lng());
		} else {
			$('#map_location_' + this.hash + ' input.latitude').val(null);
			$('#map_location_' + this.hash + ' input.longitude').val(null);
		}
		return true;
	},
	updateMap: function()
	{
		var latitude = parseFloat($('#map_location_' + this.hash + ' input.latitude').val());
		var longitude = parseFloat($('#map_location_' + this.hash + ' input.longitude').val());
		if (latitude && longitude) {
			this.setMarker(latitude, longitude);
		} else {
			this.removeMarker();
		}
		return true;
	},
	setMarker: function(latitude, longitude)
	{
		var _this = this;
		if (this.marker == null) {
			this.marker = new google.maps.Marker({
				map: this.map,
				draggable: true,
				position: {lat: latitude, lng: longitude}
			});
			this.marker.addListener('dragend', function(event) {
				_this.updateInputs();
			});
			this.marker.addListener('click', function() {
				_this.removeMarker();
				_this.updateInputs();
			});
		} else {
			this.marker.setPosition({lat: latitude, lng: longitude});
		}
		this.map.panTo({lat: latitude, lng: longitude});
		return true;
	},
	removeMarker: function()
	{
		if (this.marker != null) {
			this.marker.setMap(null);
			this.marker = null;
		}
		return true;
	},
	ready: function()
	{
		var _this = this;
		var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);
		var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);
		var zoom = (this.options.zoom ? this.options.zoom : this.DEFAULT_ZOOM);
		var mapCanvas = $('#map_location_' + this.hash + ' .mapbox').get(0);
		var mapPosition = new google.maps.LatLng(latitude, longitude);
		var mapOptions = {
			center: mapPosition,
			zoom: zoom,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
		}
		this.map = new google.maps.Map(mapCanvas, mapOptions);
		google.maps.event.addListener(this.map, 'click', function(event) {
			_this.setMarker(event.latLng.lat(), event.latLng.lng());
			_this.updateInputs();
		});
		$('#map_location_' + this.hash + ' input.latitude').on('change', function() { _this.updateMap(); });
		$('#map_location_' + this.hash + ' input.longitude').on('change', function() { _this.updateMap(); });
		this.updateMap();
	},
	repair: function()
	{
		google.maps.event.trigger(this.map, 'resize');
		this.updateMap();
	}
}