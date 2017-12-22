/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Parametrized Checkboxes                                          */
/*                                                                           */
/* Author:                                                                   */
/* Date  : 22. 12. 2017                                                      */
/*                                                                           */
/*****************************************************************************/

function RugFormParametrizedCheckboxes(hash, options)
{
	this.hash = hash;
	this.$parametrizedCheckboxes = null;
	this.$backendInput = null;
	this.$frontend = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormParametrizedCheckboxes.prototype = {
	constructor: RugFormParametrizedCheckboxes,
	updateFrontend: function()
	{
		var _this = this;
		var value = _this.$backendInput.val();
		var values = null;
		if (value) {
			values = JSON.parse(_this.$backendInput.val());
		}

		// Uncheck all checkboxes and erase parameter inputs
		_this.$frontend.find('.item :checkbox').prop('checked', false);
		_this.$frontend.find('.item input.parameter').val('');

		// Check only correct checkboxes and fill parameter
		if (values instanceof Array) {
			for (var idx = 0; idx < values.length; ++idx) {
				if (values[idx] instanceof Array) {
					var value = values[idx][0]
					var parameter = values[idx][1]

					// Find checkbox and parameter input
					var $checkbox = _this.$frontend.find('.item :checkbox[value=' + value + ']');
					var $parameterInput = $checkbox.closest('.item').find('input.parameter');

					// Check and fill parameter value
					$checkbox.prop('checked', true);
					$parameterInput.val(parameter);
				}
			}
		}
	},
	updateBackend: function()
	{
		var _this = this;
		var values = [];
		_this.$frontend.find('.item :checkbox').each(function() {
			var $this = $(this);
			if ($this.is(':checked')) {
				var $parameterInput = $this.closest('.item').find('input.parameter');
				values.push([$this.val(), $parameterInput.val()]);
			}
		});
		_this.$backendInput.val(JSON.stringify(values));
	},
	showOrHideParameter: function($checkbox)
	{
		var $parameterWrapper = $checkbox.closest('.item').find('.parameter-wrapper');
		if ($checkbox.is(':checked')) {
			$parameterWrapper.show();
		} else {
			$parameterWrapper.hide();
		}
	},
	showOrHideParameters: function()
	{
		var _this = this;
		_this.$frontend.find('.item :checkbox').each(function() {
			_this.showOrHideParameter($(this));
		});
	},
	ready: function()
	{
		var _this = this;
		
		_this.$parametrizedCheckboxes = $('#parametrized-checkboxes-' + _this.hash);
		_this.$backendInput = _this.$parametrizedCheckboxes.find('.backend input');
		_this.$frontend = _this.$parametrizedCheckboxes.find('.frontend');
		
		// Checkboxes and inputs
		_this.$frontend.find('.item input').on('change', function(e) {
			_this.updateBackend();
		});

		// Showing / hiding
		_this.$frontend.find('.item :checkbox').on('change', function(e) {
			_this.showOrHideParameter($(this));
		});
		
		// Initial value
		_this.updateFrontend();
		_this.showOrHideParameters();
	}
}