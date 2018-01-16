/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Phone                                                            */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 16. 1. 2018                                                       */
/*                                                                           */
/*****************************************************************************/

function RugFormPhone(hash, options)
{
	this.hash = hash;
	this.$phone = null;
	this.cleave = null;
	this.$backend = null;
	this.$frontendPrefix = null;
	this.$frontendsuffix = null;
	this.defaultPrefix = '+420';
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormPhone.prototype = {
	constructor: RugFormPhone,
	updateFrontend: function()
	{
		var _this = this;
		var value = _this.$backend.val()
		if (value) {
			if (value.startsWith('+')) {
				valuePrefix = value.substr(0, 4);
				valueSuffix = value.substr(4);
			} else {
				valuePrefix = _this.defaultPrefix;
				valueSuffix = value;
			}
			_this.$frontendPrefix.val(valuePrefix);
			_this.$frontendSuffix.val(valueSuffix);
		} else {
			_this.$frontendPrefix.val(_this.defaultPrefix);
			_this.$frontendSuffix.val('');
		}
	},
	updateBackend: function()
	{
		var _this = this;
		var valuePrefix = _this.$frontendPrefix.val();
		var valueSuffix = _this.$frontendSuffix.val();
		if (valuePrefix && valueSuffix) {
			_this.$backend.val(valuePrefix + ' ' + valueSuffix);
		} else {
			_this.$backend.val('');
		}
	},
	ready: function()
	{
		var _this = this;
		_this.$phone = $('#phone-' + _this.hash);
		_this.$backend = _this.$phone.find('.backend input');
		_this.$frontendPrefix = _this.$phone.find('.frontend .prefix');
		_this.$frontendSuffix = _this.$phone.find('.frontend .suffix');

		_this.$frontendPrefix.on('change', function() {
			_this.updateBackend();
		});
		_this.$frontendSuffix.on('change', function() {
			_this.updateBackend();
		});
		
		// Initial value
		_this.updateFrontend();

		// Cleave
		_this.cleave = new Cleave('#phone-' + _this.hash + ' .frontend .suffix', {
			blocks: [3, 3, 3],
			numericOnly: true
		});
	}
}