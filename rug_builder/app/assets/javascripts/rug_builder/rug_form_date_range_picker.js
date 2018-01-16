/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Date Range Picker                                                */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 3. 1. 2018                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormDateRangePicker(hash, options)
{
	this.hash = hash;
	this.$dateRangePicker = null;
	this.$backendMin = null;
	this.$backendMax = null;
	this.$frontendInput = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormDateRangePicker.prototype = {
	constructor: RugFormDateRangePicker,
	updateFrontend: function()
	{
		var _this = this;
		var valueMin = _this.$backendMin.val();
		var valueMax = _this.$backendMax.val();
		if (valueMin && valueMax) {
			_this.$frontendInput.val(valueMin + ' - ' + valueMax);
		} else {
			_this.$frontendInput.val('');
		}
	},
	updateBackend: function()
	{
		var _this = this;
		var valueDates = _this.$frontendInput.val().split(' - ');
		if (valueDates.length >= 2) {
			_this.$backendMin.val(valueDates[0]);
			_this.$backendMax.val(valueDates[1]);
		} else {
			_this.$backendMin.val('');
			_this.$backendMax.val('');
		}
	},
	ready: function()
	{
		var _this = this;
		_this.$dateRangePicker = $('#date-range-picker-' + _this.hash);
		_this.$backendMin = _this.$dateRangePicker.find('.' + _this.options['minColumn']);
		_this.$backendMax = _this.$dateRangePicker.find('.' + _this.options['maxColumn']);
		_this.$frontendInput = _this.$dateRangePicker.find('.dates');
		
		_this.$frontendInput.on('cancel.daterangepicker', function(ev, picker) {
			$(this).val('');
			_this.updateBackend();
		});
		_this.$frontendInput.on('change', function() {
			_this.updateBackend();
		});
		_this.$frontendInput.on('apply.daterangepicker', function() {
			_this.updateBackend();
		});
		
		// Initial value
		_this.updateFrontend();
	}
}