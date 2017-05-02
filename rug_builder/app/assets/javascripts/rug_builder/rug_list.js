/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug List                                                                  */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugList(hash, options)
{
	this.hash = hash;
	this.list = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugList.prototype = {
	constructor: RugList,
	addItem: function(data, options)
	{
		// Find container
		var container = null;
		container = this.list.find(this.options.containerSelector);
		if (container.length == 0) {
			container = this.list;
		}
		
		// Compose item
		var item = this.options.itemTemplate;
		for (column in data) {
			value = data[column];
			if (value == null) {
				value = "";
			}
			item = item.replace(new RegExp(':' + column, 'g'), value);
		}

		// Append or prepend new item to container	
		if (this.options.addPosition == 'prepend') {
			container.prepend(item);
		} else {
			container.append(item);
		}

		// Hide empty message
		container.find(".empty-message").hide();

		// Init destroyable if necessary
		this.inlineDestroyReady();
	},
	changeItem: function(id, data, options)
	{
		// Find container
		var container = null;
		container = this.list.find(this.options.containerSelector);
		if (container.length == 0) {
			container = this.list;
		}

		// Compose item
		var newItem = this.options.itemTemplate;
		for (column in data) {
			value = data[column];
			if (value == null) {
				value = "";
			}
			newItem = newItem.replace(new RegExp(':' + column, 'g'), value);
		}

		// Replace item
		oldItem = container.find(this.options.itemSelector + '[data-id="' + id + '"]');
		if (oldItem.length > 0) {
			oldItem.replaceWith(newItem);
		} else {
			if (this.options.addPosition == 'prepend') {
				container.prepend(newItem);
			} else {
				container.append(newItem);
			}
		}

		// Hide empty message
		container.find(".empty-message").hide();
	},
	removeItem: function(id)
	{
		// Find container
		var container = null;
		container = this.list.find(this.options.containerSelector);
		if (container.length == 0) {
			container = this.list;
		}

		// Find and remove item
		item = container.find(this.options.itemSelector + '[data-id="' + id + '"]');
		item.remove();
	},
	inlineDestroyReady: function()
	{
		if (this.options.inlineDestroy == true) {
			this.list.find(".destroyable").destroyable({
				confirmTitle: this.options.inlineDestroyConfirmTitle,
				confirmMessage: this.options.inlineDestroyConfirmMessage,
				successMessage: this.options.inlineDestroySuccessMessage,
				errorMessage: this.options.inlineDestroyErrorMessage,
			});
		}
	},
	ready: function()
	{
		var _this = this;
		this.list = $('#list-' + this.hash);

		this.inlineDestroyReady();
	}
}