/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Store                                                            */
/*                                                                           */
/* Author:                                                                   */
/* Date  : 22. 12. 2017                                                      */
/*                                                                           */
/*****************************************************************************/

function RugFormStore(hash, options)
{
	this.hash = hash;
	this.$store = null;
	this.$backendInput = null;
	this.$frontend = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugFormStore.prototype = {
	constructor: RugFormStore,
	updateFrontend: function()
	{
		var _this = this;
		var value = _this.$backendInput.val();
		var values = null;
		if (value) {
			values = JSON.parse(_this.$backendInput.val());
		}
		if (values instanceof Object) {
			for (var key in values) {
				if (values.hasOwnProperty(key)) {
					_this.addItem(key, values[key]);
				}
			}
		}
	},
	updateBackend: function()
	{
		var _this = this;
		var values = {};
		_this.$frontend.find('.item input.key').each(function() {
			var $this = $(this)
			var key = $this.val();
			var value = $this.closest('.item').find('input.value').val()
			if (key) {
				values[key] = value;
			}
		});
		_this.$backendInput.val(JSON.stringify(values));
	},
	addItem: function(key, value)
	{
		var _this = this;
		var $item = $('<div class="item">' + _this.$store.find('.template').html() + '</div>');
		
		// Inputs
		$item.find('input.key').val(key);
		$item.find('input.value').val(value);
		$item.find('input').on('change', function(e) {
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
		
		_this.$store = $('#store-' + _this.hash);
		_this.$backendInput = _this.$store.find('.backend input');
		_this.$frontend = _this.$store.find('.frontend');
		
		// Update on input change
		_this.$frontend.find('.item input').on('change', function(e) {
			_this.updateBackend();
		});

		// Register new action
		_this.$store.find('.controls .add').on('click', function(e) {
			e.preventDefault();
			_this.addItem('', '');
		});
		
		// Initial value
		_this.updateFrontend();
	}
}