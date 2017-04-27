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
	this.$inputLat = null;
	this.$inputLng = null;
	this.$exchangeButton = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormMapLocation.prototype = {
	constructor: RugFormMapLocation,
	
	// Fill correct values to inputs based on map marker
	updateInputs: function()
	{
		if (this.marker != null) {
			this.$inputLat.val(this.marker.getPosition().lat());
			this.$inputLng.val(this.marker.getPosition().lng());
		} else {
			this.$inputLat.val(null);
			this.$inputLng.val(null);
		}
		return true;
	},

	// Exchange values in inputs
	exchangeInputs: function()
	{
		var lat = this.$inputLat.val();
		var lng = this.$inputLng.val();
		this.$inputLat.val(lng);
		this.$inputLng.val(lat);
		this.updateMap();
	},

	// Convert coordinates in degree format (14°12'25.34") to decimal format
	_coordinatesToDecimal: function(value)
	{
		var result = 0.0;
		var minus = false;

		// Remove trailing symbol
		value = value.trim().replace(/[°'"]$/, '');

		// Replace decimal ',' for decimal '.'
		value = value.replace(',', '.');

		// Minus according to NSEW
		if (value.includes("S") || value.includes("W")) {
			minus = true;
			value = value.replace('-', '');
		}
		value = value.replace(/[NSEW]/, '');

		// Split
		var splitted1 = value.split('°');
		if (splitted1.length == 1) {
			
			// Degrees
			result += parseFloat(splitted1[0]);
			return result;
		
		} else if (splitted1.length == 2) {

			// Degrees
			result += parseFloat(splitted1[0]);

			// Minus correction
			if (result < 0.0) {
				minus = true;
				result = -result;
			}

			// Split
			var splitted2 = splitted1[1].trim().split("'");
			if (splitted2.length == 1) {

				// Minutes
				result += (parseFloat(splitted2[0]) / 60.0);

				// Minus correction
				if (minus) result = -result;

				return result;
			
			} else if (splitted2.length == 2) {
				
				// Minutes
				result += (parseFloat(splitted2[0]) / 60.0);

				// Seconds
				result += (parseFloat(splitted2[1]) / 3600.0);

				// Minus correction
				if (minus) result = -result;

				return result;
			}
		}
		
		return null;
	},

	// Interpret values in inputs and try to fill in correct values
	fixInputs: function($input)
	{
		var value = $input.val();
		var matched = false;
		
		if (!matched) {
			var regexps = [
				/^\s*(\d+°?[NSEW]?)\s*[\s,;]\s*(\d+°?[NSEW]?)\s*$/,
				/^\s*(\d+[,.]\d+°?[NSEW]?)\s*[\s,;]\s*(\d+[,.]\d+°?[NSEW]?)\s*$/,
				/^\s*(\d+°\s*\d+'?[NSEW]?)\s*[\s,;]\s*(\d+°\s*\d+'?[NSEW]?)\s*$/,
				/^\s*(\d+°\s*\d+[,.]\d+'?[NSEW]?)\s*[\s,;]\s*(\d+°\s*\d+[,.]\d+'?[NSEW]?)\s*$/,
				/^\s*(\d+°\s*\d+'\s*\d+"?[NSEW]?)\s*[\s,;]\s*(\d+°\s*\d+'\s*\d+"?[NSEW]?)\s*$/,
				/^\s*(\d+°\s*\d+'\s*\d+[,.]\d+"?[NSEW]?)\s*[\s,;]\s*(\d+°\s*\d+'\s*\d+[,.]\d+"?[NSEW]?)\s*$/,
			];
			for (var i = 0; i < regexps.length; ++i) {
				match = value.match(regexps[i]);
				if (match) {
					matched = true;

					this.$inputLat.val(this._coordinatesToDecimal(match[1]));
					this.$inputLng.val(this._coordinatesToDecimal(match[2]));
				}
			}
		}

		if (!matched) {
			var regexps = [
				/^\s*(\d+°?[NSEW]?)\s*$/,
				/^\s*(\d+[,.]\d+°?[NSEW]?)\s*$/,
				/^\s*(\d+°\s*\d+'?[NSEW]?)\s*$/,
				/^\s*(\d+°\s*\d+[,.]\d+'?[NSEW]?)\s*$/,
				/^\s*(\d+°\s*\d+'\s*\d+"?[NSEW]?)\s*$/,
				/^\s*(\d+°\s*\d+'\s*\d+[,.]\d+"?[NSEW]?)\s*$/,
			];
			for (var i = 0; i < regexps.length; ++i) {
				match = value.match(regexps[i]);
				if (match) {
					matched = true;

					$input.val(this._coordinatesToDecimal(match[1]));
				}
			}
		}
	},

	// Position marker based on values in inputs
	updateMap: function()
	{
		var lat = parseFloat(this.$inputLat.val());
		var lng = parseFloat(this.$inputLng.val());
		if (lat && lng) {
			this.setMarker(lat, lng);
		} else {
			this.removeMarker();
		}
		return true;
	},

	// Set marker to map
	setMarker: function(lat, lng)
	{
		var _this = this;
		if (this.marker == null) {
			this.marker = new google.maps.Marker({
				map: this.map,
				draggable: true,
				position: {lat: lat, lng: lng}
			});
			this.marker.addListener('dragend', function(event) {
				_this.updateInputs();
			});
			this.marker.addListener('click', function() {
				_this.removeMarker();
				_this.updateInputs();
			});
		} else {
			this.marker.setPosition({lat: lat, lng: lng});
		}
		this.map.panTo({lat: lat, lng: lng});
		return true;
	},

	// Remove marker from map
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
		
		// Map
		var latitude = (_this.options.latitude ? _this.options.latitude : _this.DEFAULT_LATITUDE);
		var longitude = (_this.options.longitude ? _this.options.longitude : _this.DEFAULT_LONGITUDE);
		var zoom = (_this.options.zoom ? _this.options.zoom : _this.DEFAULT_ZOOM);
		var mapCanvas = $('#map_location_' + _this.hash + ' .mapbox').get(0);
		var mapPosition = new google.maps.LatLng(latitude, longitude);
		var mapOptions = {
			center: mapPosition,
			zoom: zoom,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
		}
		_this.map = new google.maps.Map(mapCanvas, mapOptions);

		// When marker set in the map => update inputs
		google.maps.event.addListener(_this.map, 'click', function(event) {
			_this.setMarker(event.latLng.lat(), event.latLng.lng());
			_this.updateInputs();
		});

		// Inputs
		_this.$inputLat = $('#map_location_' + _this.hash + ' input.latitude');
		_this.$inputLng = $('#map_location_' + _this.hash + ' input.longitude');
		
		// When input is changed => fix values and update marker on the map
		_this.$inputLat.on('change', function() {
			_this.fixInputs(_this.$inputLat);
			_this.updateMap();
		});
		_this.$inputLng.on('change', function() {
			_this.fixInputs(_this.$inputLng);
			_this.updateMap();
		});
		
		// Update map marker according to default value
		_this.updateMap();

		// Exchange button
		_this.$exchangeButton = $('#map_location_' + _this.hash + ' .exchange');
		_this.$exchangeButton.on('click', function(e) { e.preventDefault(); _this.exchangeInputs(); });

		// Repair map on tab change
		$('a[data-toggle="tab"]').on('shown.bs.tab', this.repair.bind(this));
	},
	repair: function()
	{
		google.maps.event.trigger(this.map, 'resize');
		this.updateMap();
	}
}