/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Parametrized Checkboxes                                          */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
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
		var parametersNumber = _this.options.parameters ? parseInt(_this.options.parameters) : 1;
		var value = _this.$backendInput.val();
		var values = null;
		if (value) {
			try {
				values = JSON.parse(_this.$backendInput.val());
			} catch(e) {
				console.log('Invalid JSON data.');
			}
		}

		// Uncheck all checkboxes and erase parameter inputs
		_this.$frontend.find('.item :checkbox').prop('checked', false);
		_this.$frontend.find('.item .parameter').val('');

		// Check only correct checkboxes and fill parameter
		if (values instanceof Array) {
			for (var idx = 0; idx < values.length; ++idx) {
				if (values[idx] instanceof Array) {
					
					// Checkbox
					var value = values[idx][0]
					var $checkbox = _this.$frontend.find('.item :checkbox[value=' + value + ']');
					$checkbox.prop('checked', true);

					// Parameters
					for (var jdx = 1; jdx <= parametersNumber; ++jdx) {
						var $parameterInput = null;
						if (jdx == 1) {
							$parameterInput = $checkbox.closest('.item').find('.parameter');
						} else {
							$parameterInput = $checkbox.closest('.item').find('.parameter-' + jdx);
						}
						$parameterInput.val(values[idx][jdx]);
					}
					
				}
			}
		}
	},
	updateBackend: function()
	{
		var _this = this;
		var parametersNumber = _this.options.parameters ? parseInt(_this.options.parameters) : 1;
		var values = [];
		_this.$frontend.find('.item :checkbox').each(function() {
			var $this = $(this);
			if ($this.is(':checked')) {
				var value = [$this.val()];
				for (var jdx = 1; jdx <= parametersNumber; ++jdx) {
					var $parameterInput = null;
					if (jdx == 1) {
						$parameterInput = $this.closest('.item').find('.parameter');
					} else {
						$parameterInput = $this.closest('.item').find('.parameter-' + jdx);
					}
					value.push($parameterInput.val());
				}
				values.push(value);
			}
		});
		_this.$backendInput.val(JSON.stringify(values));
	},
	processParameter: function($checkbox)
	{
		var _this = this;
		var parametersNumber = _this.options.parameters ? parseInt(_this.options.parameters) : 1;
		if (_this.options.processParameter.hide) {
			var $parameterWrapper = $checkbox.closest('.item').find('.parameter-wrapper');
			if ($checkbox.is(':checked')) {
				$parameterWrapper.show();
			} else {
				$parameterWrapper.hide();
			}
		}
		for (var jdx = 1; jdx <= parametersNumber; ++jdx) {
			var $parameterInput = null;
			if (jdx == 1) {
				$parameterInput = $checkbox.closest('.item').find('.parameter');
			} else {
				$parameterInput = $checkbox.closest('.item').find('.parameter-' + jdx);
			}
			if (_this.options.processParameter.disable) {
				if ($checkbox.is(':checked')) {
					$parameterInput.prop('disabled', false);
				} else {
					$parameterInput.prop('disabled', true);
				}
			}
			if (_this.options.processParameter.clear) {
				if (!$checkbox.is(':checked')) {
					$parameterInput.val('');
				}
			}
		}
	},
	processParameters: function()
	{
		var _this = this;
		_this.$frontend.find('.item :checkbox').each(function() {
			_this.processParameter($(this));
		});
	},
	computeTotal: function()
	{
		var _this = this;
		var total = 0;
		_this.$frontend.find('.item :checkbox').each(function() {
			$checkbox = $(this);
			if ($checkbox.is(':checked')) {
				var $parameter = $checkbox.closest('.item').find('.parameter');
				var value = parseInt($parameter.val());
				if (value) {
					total += value;
				}
			}
		});
		var $total = _this.$frontend.find('.total input');
		if (total > 0) {
			$total.val(total);
		} else {
			$total.val('');
		}
	},
	ready: function()
	{
		var _this = this;
		
		_this.$parametrizedCheckboxes = $('#parametrized-checkboxes-' + _this.hash);
		_this.$backendInput = _this.$parametrizedCheckboxes.find('.backend input');
		_this.$frontend = _this.$parametrizedCheckboxes.find('.frontend');
		
		// Checkboxes and inputs
		_this.$frontend.find('.item input, .item select').on('change', function(e) {
			_this.updateBackend();
			if (_this.options.computeTotal) {
				_this.computeTotal();
			}
		});

		// Process param
		_this.$frontend.find('.item :checkbox').on('change', function(e) {
			_this.processParameter($(this));
			if (_this.options.computeTotal) {
				_this.computeTotal();
			}
		});
		
		// Initial value
		_this.updateFrontend();
		_this.processParameters();
		if (_this.options.computeTotal) {
			_this.computeTotal();
		}
	}
}