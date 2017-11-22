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
			this.showSection(!this.readyInProgress);
		} else {
			this.hideSection(!this.readyInProgress);
		}

		this.readyInProgress = false;
	},

	showSection: function(animate) {
		if (!animate) {
			this.conditionalSection.show();
		} else {
			this.conditionalSection.slideDown();
		}
	},

	hideSection: function(animate) {
		if (!animate) {
			this.conditionalSection.hide();
		} else {
			this.conditionalSection.slideUp();
		}
	},

	onElementChange: function(element) {
		var $element = $(element);

		if ($element.is(':radio')) {
			// Interpret value only if radio button is selected
			if ($element.is(':checked')) {
				this.interpret($element.val());
			}

		} else if ($element.is(':checkbox')) {
			// Convert checkbox checked/unchecked to true/false boolean values
			this.interpret($element.is(":checked"));

		} else {
			// Pass value for other elements
			this.interpret($element.val());
		}
	},

	ready: function()
	{
		var self = this;

		// Get form
		var $form = $(this.options.formSelector);
				
		// Get only those elements, which have "id" attribute. This will
		// skip special Rails hidden inputs for checkboxes.
		var $elements = $form.find('[name="' + this.options.conditionName + '"][id!=""][id]');

		// Initialize
		this.conditionalSection.hide();
		$elements.each(function() {
			self.onElementChange(this);
		});

		// Set up change callback
		$elements.change(function() {
			self.onElementChange(this);
		});
	},
}