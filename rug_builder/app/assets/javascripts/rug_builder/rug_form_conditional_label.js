/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Conditional Label                                              */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugFormConditionalLabel(hash, options)
{
	this.hash = hash;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormConditionalLabel.prototype = {
	constructor: RugFormConditionalLabel,

	interpret: function(value)
	{
		eval('var conditionRule = (' + this.options.conditionRule + ');');

		if (conditionRule) {
			if (this.options.conditionEffect.hide) {
				this.hideLabel(this.options.conditionEffect.hide);
			}
			if (this.options.conditionEffect.show) {
				this.showLabel(this.options.conditionEffect.show);
			}
		} else {
			if (this.options.conditionEffect.show) {
				this.hideLabel(this.options.conditionEffect.show);
			}
			if (this.options.conditionEffect.hide) {
				this.showLabel(this.options.conditionEffect.hide);
			}
		}

		this.readyInProgress = false;
	},

	toCamelCase: function(str) {
		return str.split('-').map(function(word,index){
			return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
		}).join('');
	},

	showLabel: function(label) {
		var self = this;
		
		// Labels
		self.$form.find('label').each(function() {
			var text = $(this).data('conditional' + self.toCamelCase(label));
			if (text) {
				$(this).text(text);
			}
		});

		// Input placeholders
		self.$form.find('input').each(function() {
			var text = $(this).data('conditional' + self.toCamelCase(label));
			if (text) {
				$(this).attr('placeholder', text);
			}
		});
	},

	hideLabel: function(label) {
		// TODO ???
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

	reload: function()
	{
		var self = this;
		self.$elements.each(function() {
			self.onElementChange(this);
		});
	},

	ready: function()
	{
		var self = this;

		// Get form
		self.$form = $(this.options.formSelector);
				
		// Get only those elements, which have "id" attribute. This will
		// skip special Rails hidden inputs for checkboxes.
		self.$elements = self.$form.find('[name="' + this.options.conditionName + '"][id!=""][id]');

		// Initialize
		self.reload();

		// Set up change callback
		self.$elements.change(function() {
			self.onElementChange(this);
		});
	},
}