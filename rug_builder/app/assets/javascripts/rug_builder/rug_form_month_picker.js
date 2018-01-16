/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Month Picker                                                     */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 3. 1. 2018                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormMonthPicker(hash, options)
{
	this.hash = hash;
	this.$monthPicker = null;
	this.$backend = null;
	this.$frontendMonth = null;
	this.$frontendYear = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormMonthPicker.prototype = {
	constructor: RugFormMonthPicker,
	updateFrontend: function()
	{
		var _this = this;
		var value = _this.$backend.val()
		if (value) {
			var date = moment(value, 'D. M. YYYY');
			_this.$frontendMonth.val(date.month() + 1);
			_this.$frontendYear.val(date.year());
		} else {
			_this.$frontendMonth.val('');
			_this.$frontendYear.val('');
		}
	},
	updateBackend: function()
	{
		var _this = this;
		var valueMonth = _this.$frontendMonth.val();
		var valueYear = _this.$frontendYear.val();
		if (valueMonth && valueYear) {
			_this.$backend.val('1. ' + valueMonth + '. ' + valueYear);
		} else {
			_this.$backend.val('');
		}
	},
	ready: function()
	{
		var _this = this;
		_this.$monthPicker = $('#month-picker-' + _this.hash);
		_this.$backend = _this.$monthPicker.find('.backend');
		_this.$frontendYear = _this.$monthPicker.find('.frontend.year');
		_this.$frontendMonth = _this.$monthPicker.find('.frontend.month');
		
		_this.$frontendYear.on('change', function() {
			_this.updateBackend();
		});
		_this.$frontendMonth.on('change', function() {
			_this.updateBackend();
		});
		
		// Initial value
		_this.updateFrontend();
	}
}