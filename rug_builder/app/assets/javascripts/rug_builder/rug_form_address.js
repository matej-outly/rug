/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Address                                                          */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 3. 1. 2018                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormAddress(hash, options)
{
	this.hash = hash;
	this.geocoderObject = null;
	this.$address = null;
	this.lockTimer = null;
	this.lockValue = '';
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormAddress.prototype = {
	constructor: RugFormAddress,
	
	geocoder: function()
	{
		if (this.geocoderObject == null) {
			this.geocoderObject = new google.maps.Geocoder();
		}
		return this.geocoderObject
	},

	suggest: function(address, callback) {
		var _this = this;
		var completeResults = [];
		
		// Request to CZ
		_this.geocoder().geocode({
			'address': address,
			'componentRestrictions': {'country': 'CZ' },
		}, function(results, status) {

			// Collect results
			if (status === google.maps.GeocoderStatus.OK) {
				for (i = 0; i < results.length; i++) { 
					if (results[i].partial_match != true) {
						completeResults.push(results[i]);
						console.log(results[i]);
					}
				}
			}

			// Callback
			if (typeof callback === 'function') callback(completeResults);

		});
	},

	value: function()
	{
		var _this = this;
		var street = _this.$inputStreet.val();
		var number = _this.$inputNumber.val();
		var city = _this.$inputCity.val();
		var zipcode = _this.$inputZipcode.val();
		var result = '';
		if (street) result += street;
		if (number && result) result += ' ';
		if (number) result += number;
		if (zipcode && result) result += ', ';
		if (zipcode) result += zipcode;
		if (city && result) result += ', ';
		if (city) result += city;
		return result;
	},

	onKeypress: function(timeout)
	{
		var _this = this;
		
		// Clear timer if active
		if (this.lockTimer != null) {
			clearTimeout(this.lockTimer);
		}
		
		// Save term
		this.lockValue = _this.value();

		// Activate timer with new settings
		this.lockTimer = setTimeout(function() {
			_this.lockTimer = null;
			_this.updateSuggestions(_this.lockValue);
		}, timeout);
	},

	updateSuggestions: function(value)
	{
		var _this = this;
		
		_this.suggest(value, function(results) {

			// Clear suggestions
			_this.$suggestions.empty();

			// Append found suggestions
			if (results && results.length > 0) {
				for (i = 0; i < results.length; i++) {
					
					// Parse address
					var street = '';
					var descriptive_number = '';
					var orientation_number = '';
					var city = '';
					var zipcode = '';
					for (j = 0; j < results[i].address_components.length; j++) {
						if (results[i].address_components[j].types.includes('street_number')) orientation_number = results[i].address_components[j].long_name;
						if (results[i].address_components[j].types.includes('premise')) descriptive_number = results[i].address_components[j].long_name;
						if (results[i].address_components[j].types.includes('route')) street = results[i].address_components[j].long_name;
						if (results[i].address_components[j].types.includes('administrative_area_level_2')) city = results[i].address_components[j].long_name;
						if (results[i].address_components[j].types.includes('postal_code')) zipcode = results[i].address_components[j].long_name;
					}
					number = []
					if (descriptive_number) number.push(descriptive_number);
					if (orientation_number) number.push(orientation_number)
					number = number.join('/');

					// Create element
					var $suggestion = $('<div class="suggestion alert alert-info" data-id="' + i + '" data-street="' + street + '" data-number="' + number + '" data-city="' + city + '" data-zipcode="' + zipcode + '">' + results[i].formatted_address + '</div>');
					$suggestion.click(function() {
						_this.selectSuggestion($(this).data('id'));
					});

					// Append
					_this.$suggestions.append($suggestion);
				}
			}

		});
	},

	selectSuggestion: function(id)
	{
		var _this = this;
		$suggestion = _this.$suggestions.find('.suggestion[data-id=' + id + ']');
		if ($suggestion.length > 0) {
			_this.$inputStreet.val( $suggestion.data('street') );
			_this.$inputNumber.val( $suggestion.data('number') );
			_this.$inputCity.val( $suggestion.data('city') );
			_this.$inputZipcode.val( $suggestion.data('zipcode') );

			// Clear suggestions
			_this.$suggestions.empty();
		}
	},

	ready: function()
	{
		var _this = this;
		
		// Elements
		_this.$address = $('#address-' + _this.hash);
		_this.$inputStreet = _this.$address.find('input.street');
		_this.$inputNumber = _this.$address.find('input.number');
		_this.$inputCity = _this.$address.find('input.city');
		_this.$inputZipcode = _this.$address.find('input.zipcode');
		_this.$suggestions = _this.$address.find('.suggestions');

		_this.$inputStreet.keyup(function() { _this.onKeypress(500); });
		_this.$inputNumber.keyup(function() { _this.onKeypress(500); });
	}
}