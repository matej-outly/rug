/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Index                                                                 */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugIndex(hash, options)
{
	this.hash = hash;
	this.$index = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}

RugIndex.prototype = {
	constructor: RugIndex,
	
	reload: function(id)
	{
		var _this = this;
		if (this.options.reloadable) {
			var reloadUrl = this.options.reloadable.url.replace(':id', id);
			$.get(reloadUrl, function(data) {
				if (parseInt(data[0]['id']) == parseInt(id)) {
					_this.addItem(id, data[0]['html']);
				}
			}, 'json');	
		}
	},

	getContainer: function()
	{
		var $container = this.$index.find(this.options.containerSelector + ' ' + this.options.itemPath);
		if ($container.length == 0) {
			$container = this.$index;
		}
		return $container
	},
	
	addItem: function(id, html, options)
	{
		// Find container
		var $container = this.getContainer();

		// Add item or replace existing item if found
		var $item = $container.find(this.options.itemSelector + '[data-id="' + id + '"]');
		if ($item.length > 0) {
			$item.replaceWith(html);
		} else {
			if (this.options.addPosition == 'append') {
				$container.append(html);
			} else {
				$container.prepend(html);
			}
		}

		// Hide empty message
		$container.find(".empty-message").hide();
	},

	removeItem: function(id)
	{
		// Find container
		var $container = this.getContainer();

		// Find and remove item
		var $item = $container.find(this.options.itemSelector + '[data-id="' + id + '"]');
		$item.remove();
	},

	ready: function()
	{
		this.$index = $('#index-' + this.hash);
		this.readyMove();
		this.readyTiles();
		this.readyDestroyable();
	},
	
	readyMove: function()
	{
		var _this = this;
		if (this.options.move && this.$index.hasClass('moving')) {
			this.$index.sortable({
				containerSelector: this.options.containerSelector,
				itemPath: this.options.itemPath,
				itemSelector: this.options.itemSelector,
				placeholder: this.options.move.placeholder,
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
						var moveUrl = _this.options.move.url.replace(':id', id).replace(':relation', relation).replace(':destination_id', destinationId);
						$.ajax({url: moveUrl, method: 'PUT', dataType: 'json'});
					}
				}
			});
		}
	},
	
	readyTiles: function()
	{
		if (this.options.tiles == true) {
			this.$index.find('.item').tileResizer({
				resize: ['.caption'],
			});
		}
	},

	readyDestroyable: function()
	{
		if (this.options.destroyable) {
			this.$index.find(".destroyable").destroyable({
				confirmTitle: this.options.destroyable.confirmTitle,
				confirmMessage: this.options.destroyable.confirmMessage,
				successMessage: this.options.destroyable.successMessage,
				errorMessage: this.options.destroyable.errorMessage,
			});
		}
	}
}