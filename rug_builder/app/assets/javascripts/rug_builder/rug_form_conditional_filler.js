/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Conditional Filler                                               */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormConditionalFiller(options)
{
	this.$form = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormConditionalFiller.prototype = {
	constructor: RugFormConditionalFiller,

	interpret: function() {
		var self = this;

		var inputValues = [];
		self.inputs().forEach(function($input) {

			var value = null;
			if ($input.length == 1) {
				if ($input.is(':checkbox')) {
					// Convert checkbox checked/unchecked to true/false boolean values
					value = $input.is(":checked");
				} else {
					// Pass value for other elements
					value = $input.val();
				}
			} else {
				value = [];
				$input.each(function() {
					var $element = $(this);
					if ($element.is(':checkbox')) {
						// Convert checkbox checked/unchecked to true/false boolean values
						value.push($element.is(":checked"));
					} else {
						// Pass value for other elements
						value.push($element.val());
					}
				});
			}

			inputValues.push(value);
		});

		// Apply
		var outputValue = self.options.rule.apply(null, inputValues);

		// Set to output
		self.output().val(outputValue);
	},

	inputs: function() {
		var self = this;
		$inputs = [];
		this.options.inputSelectors.forEach(function(inputSelector) {
			
			// Get only those elements, which have "id" attribute. This will
			// skip special Rails hidden inputs for checkboxes.
			$inputs.push( self.$form.find(inputSelector + '[id!=""][id]') );
		});
		return $inputs;
	},

	output: function() {
		var self = this;
		return self.$form.find(self.options.outputSelector);
	},

	ready: function()
	{
		var self = this;

		// Get form
		self.$form = $(this.options.formSelector);
		
		// Initialize
		self.interpret();
		
		// Set up change callback
		self.inputs().forEach(function($input) {
			$input.change(function() {
				self.interpret();
			});
		});
	},
}