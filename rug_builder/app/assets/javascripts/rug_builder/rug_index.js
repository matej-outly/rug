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

	// Pagination
	this.page = 1;
	this.isLastPage = false;
	this.$paginateLink = null;
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

	paginate: function()
	{
		var _this = this;
		if (this.options.paginateable && !this.isLastPage) {
			_this.page += 1;
			var paginateUrl = this.options.paginateable.url.replace(':page', _this.page);
			$.get(paginateUrl, function(data) {
				if (data.constructor == Array) {
					data.forEach(function(item) {
						_this.addItem(item['id'], item['html']);
					});
					if (data.length <= 0) {
						_this.isLastPage = true;
						if (_this.$paginateLink) {
							_this.$paginateLink.hide();
						}
					}
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

		// Reload JS events
		this.readyTilable();
		this.readyDestroyable();
		// TODO activate modals if added...
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
		this.readyMovable();
		this.readyTilable();
		this.readyDestroyable();
		this.readyPaginateable();
		this.readySortable();
	},
	
	readyMovable: function()
	{
		var _this = this;
		if (this.options.movable && this.$index.hasClass('movable')) {
			this.$index.sortable({
				containerSelector: this.options.containerSelector,
				itemPath: this.options.itemPath,
				itemSelector: this.options.itemSelector,
				placeholder: this.options.movable.placeholder,
				handle: '.move-handle',
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
						var moveUrl = _this.options.movable.url.replace(':id', id).replace(':relation', relation).replace(':destination_id', destinationId);
						$.ajax({url: moveUrl, method: 'PUT', dataType: 'json'});
					}
				}
			});
		}
	},
	
	readyTilable: function()
	{
		if (this.options.tilable == true) {
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
	},

	readyPaginateable: function()
	{
		var _this = this;
		if (this.options.paginateable) {
			_this.$paginateLink = this.$index.parent().find('.paginate-link');
			_this.$paginateLink.click(function(e) {
				e.preventDefault();
				_this.paginate();
			});
		}
	},

	readySortable: function()
	{
		if (this.options.sortable) {
			console.log(document.getElementById('index-' + this.hash));
			new Tablesort(document.getElementById('index-' + this.hash));
		}
	}

}