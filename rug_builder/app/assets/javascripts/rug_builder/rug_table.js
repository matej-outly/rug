/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Table                                                                 */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugTable(hash, options)
{
	this.hash = hash;
	this.table = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugTable.prototype = {
	constructor: RugTable,
	addItem: function(data, options)
	{
		// Find container
		var container = null;
		container = this.table.find(this.options.containerSelector + ' ' + this.options.itemSelectorPath);
		if (container.length == 0) {
			container = this.table;
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
		container.append(item);

		// Hide empty message
		container.find(".empty-message").hide();

		// Init destroyable if necessary
		this.inlineDestroyReady();
	},
	removeItem: function(id)
	{
		// Find container
		var container = null;
		container = this.table.find(this.options.containerSelector + ' ' + this.options.itemSelectorPath);
		if (container.length == 0) {
			container = this.table;
		}

		// Find and remove item
		item = container.find(this.options.itemSelector + '[data-id="' + id + '"]');
		item.remove();
	},
	movingReady: function()
	{
		var _this = this;
		if (this.options.moving == true && this.table.hasClass('moving')) {
			this.table.sortable({
				containerSelector: this.options.containerSelector,
				itemPath: this.options.itemSelectorPath,
				itemSelector: this.options.itemSelector,
				placeholder: this.options.movingPlaceholder,
				handle: '.moving-handle',
				onDrop: function ($item, container, _super, event) {
					$item.removeClass(container.group.options.draggedClass).removeAttr('style');
					$('body').removeClass(container.group.options.bodyClass);
					var id = $item.data('id');
					var prevId = $item.prev().data('id') ? $item.prev().data('id') : undefined;
					var nextId = $item.next().data('id') ? $item.next().data('id') : undefined;
					if (prevId || nextId) {
						var destinationId = prevId;
						var relation = 'right';
						if (!destinationId) {
							destinationId = nextId;
							relation = 'left';
						}
						var moveUrl = _this.options.movingUrl.replace(':id', id).replace(':relation', relation).replace(':destination_id', destinationId);
						$.ajax({url: moveUrl, method: 'PUT', dataType: 'json'});
					}
				}
			});
		}
	},
	inlineDestroyReady: function()
	{
		if (this.options.inlineDestroy == true) {
			this.table.find(".destroyable").destroyable({
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
		this.table = $('#index-table-' + this.hash);

		this.movingReady();
		this.inlineDestroyReady();
	}
}