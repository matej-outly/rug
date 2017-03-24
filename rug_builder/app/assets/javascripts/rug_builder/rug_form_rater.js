/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Rater                                                            */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormRater(hash, options)
{
	this.hash = hash;
	this.rater = null;
	this.input = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormRater.prototype = {
	constructor: RugFormRater,
	updateRater: function()
	{
		this.rater.rate("setValue", this.input.val());
	},
	updateInput: function()
	{
		this.input.val(this.rater.rate("getValue"));
	},
	ready: function()
	{
		var _this = this;
		
		// jQuery objects
		_this.rater = $('#rater_' + _this.hash + ' .canvas');
		_this.input = $('#rater_' + _this.hash + ' input');

		var max = (_this.options.max ? _this.options.max : 5);
		var step = (_this.options.step ? _this.options.step : 5);

		// Init
		_this.rater.rate({ 
			max_value: max,
			step_size: step,
			symbols: {
				custom: {
					base: _this.options.symbolBase,
					hover: _this.options.symbolHover,
					selected: _this.options.symbolSelected,
				},
			},
			selected_symbol_type: 'custom',
		});

		// On change
		_this.rater.on('change', function(e, data){
			_this.updateInput();
		});

		// HACK to ensure canvas width (not working correctlly sometimes)
		_this.rater.width(max * 33.4);
		
		// Initial value
		_this.updateRater();
	}
}