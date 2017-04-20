/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Chart                                                                 */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 20. 4. 2017                                                       */
/*                                                                           */
/*****************************************************************************/

function RugChart(hash, options)
{
	this.hash = hash;
	this.$dateFrom = null;
	this.$dateTo = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugChart.prototype = {
	constructor: RugChart,
	reload: function()
	{
		var dateFrom = this.$dateFrom.val();
		var dateTo = this.$dateTo.val();
		var path = this.options.path;
		var params = [];
		if (dateFrom) {
			params.push('from=' + dateFrom)
		}
		if (dateTo) {
			params.push('to=' + dateTo)
		}
		var chartOptions = Chartkick.charts[this.options.id].getOptions();
		new Chartkick[this.options.type[0].toUpperCase() + this.options.type.slice(1) + 'Chart'](this.options.id, path + '?' + params.join('&'), chartOptions);
	},
	readyDatePicker: function($datePicker)
	{
		$datePicker.pikaday({ 
			firstDay: 1,
			format: 'YYYY-MM-DD',
			i18n: this.options.i18n,
		});
		$datePicker.on('change', this.reload.bind(this));
	},
	ready: function()
	{
		// jQuery objects
		this.$dateFrom = $('#chart-' + this.hash + ' .date-from');
		this.$dateTo = $('#chart-' + this.hash + ' .date-to');

		// Init date pickers
		this.readyDatePicker(this.$dateFrom);
		this.readyDatePicker(this.$dateTo);

		// Reload chart on tab change
		$('a[data-toggle="tab"]').on('shown.bs.tab', this.reload.bind(this));
	}
}

RugChart.setup = function(options)
{
	Chartkick.configure({
		'language': options.language
	});
}

