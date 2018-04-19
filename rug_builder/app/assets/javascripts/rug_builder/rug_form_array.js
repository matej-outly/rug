/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Array                                                            */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 22. 12. 2017                                                      */
/*                                                                           */
/*****************************************************************************/

function RugFormArray(hash, options)
{
	this.hash = hash;
	this.$array = null;
	this.$backendInput = null;
	this.$frontend = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormArray.prototype = {
	constructor: RugFormArray,
	updateFrontend: function()
	{
		var _this = this;
		var value = _this.$backendInput.val();
		var values = null;
		if (value) {
			try {
				values = JSON.parse(_this.$backendInput.val());
			} catch(e) {
				console.log('Invalid JSON data.');
			}
		}
		if (values instanceof Array) {
			for (var idx = 0; idx < values.length; ++idx) {
				_this.addItem(values[idx]);
			}
		}
	},
	updateBackend: function()
	{
		var _this = this;
		var values = [];
		_this.$frontend.find('.item').each(function() {
			var item = {};
			var simple = false;
			var empty = true
			$(this).find('input.value, select.value, textarea.value').each(function() {
				var value = $(this).val();
				var attr = $(this).data('attr');
				if (value) {
					empty = false;
					if (attr) {
						item[attr] = value
					} else {
						item = value;
						simple = true;
					}
				}
			});
			if (!empty) {
				values.push(item);
			}
		});
		_this.$backendInput.val(JSON.stringify(values));
	},
	addItem: function(value)
	{
		var _this = this;
		var $item = $('<div class="item">' + _this.$array.find('.template').html() + '</div>');
		
		// Input / select
		$item.find('input.value, select.value, textarea.value').each(function() {
			var attr = $(this).data('attr');
			if (attr) {
				$(this).val(value[attr]);
			} else {
				$(this).val(value);
			}
		});
		$item.find('input.value, select.value, textarea.value').on('change', function(e) {
			_this.updateBackend();
		});

		// Register destroy action
		$item.find('.remove').on('click', function(e) {
			e.preventDefault();
			$(this).closest('.item').remove();
			_this.updateBackend();
		});

		// Add into frontend
		_this.$frontend.append($item);
	},
	ready: function()
	{
		var _this = this;
		
		_this.$array = $('#array-' + _this.hash);
		_this.$backendInput = _this.$array.find('.backend input');
		_this.$frontend = _this.$array.find('.frontend');
		
		// Input / select
		_this.$frontend.find('.item ' + _this.frontendElement).on('change', function(e) {
			_this.updateBackend();
		});

		// Register new action
		_this.$array.find('.controls .add').on('click', function(e) {
			e.preventDefault();
			_this.addItem('');
		});
		
		// Initial value
		_this.updateFrontend();
	}
}