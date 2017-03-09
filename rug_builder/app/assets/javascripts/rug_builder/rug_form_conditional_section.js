/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Conditional Section                                              */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormConditionalSection(hash, options)
{
	this.hash = hash;
	this.conditionalSection = $('#conditional-section-' + hash);
	this.readyInProgress = true;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormConditionalSection.prototype = {
	constructor: RugFormConditionalSection,
	interpret: function(value)
	{
		eval('var conditionRule = (' + this.options.conditionRule + ');');
		if (conditionRule) {
			if (this.readyInProgress) {
				this.conditionalSection.show();
			} else {
				this.conditionalSection.slideDown();
			}
		} else {
			if (this.readyInProgress) {
				this.conditionalSection.hide();
			} else {
				this.conditionalSection.slideUp();
			}
		}
		this.readyInProgress = false;
	},
	ready: function()
	{
		var _this = this;
		this.conditionalSection.hide();
		$('[name="' + _this.options.conditionName + '"]').on('change', function(e) {
			var __this = $(this);
			if (__this.is(':radio')) {
				if (__this.is(':checked')) {
					_this.interpret(__this.val());
				}
			} else {
				_this.interpret(__this.val());
			}
		}).trigger('change');
	}
}