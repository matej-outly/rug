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
		var self = this;
		self.conditionalSection.hide();
		$('[name="' + self.options.conditionName + '"]').change(function() {
			var $element = $(this);

			if ($element.is(':radio')) {
				// Interpret value only if radio button is selected
				if ($element.is(':checked')) {
					self.interpret($element.val());
				}

			} else if ($element.is(':checkbox')) {
				// Convert checkbox checked/unchecked to true/false boolean values
				self.interpret($element.is(":checked"));

			} else {
				// Pass value for other elements
				self.interpret($element.val());
			}

		}).trigger('change');
	}
}