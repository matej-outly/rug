/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Tree                                                                  */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

function RugTree(hash, options)
{
	this.hash = hash;
	this.tree = null;
	this.storageKey = 'rug_tree_' + hash;
	this.options = (typeof options !== 'undefined' ? options : {});
	this.inEditation = false;
}

RugTree.prototype = {
	constructor: RugTree,
	getData: function() {
		return this.tree.tree('getTree').getData();
	},
	loadData: function(data) {
		return this.tree.tree('loadData', data);
	},
	getDataAsJson: function() {
		return this.tree.tree('toJson');
	},
	loadDataAsJson: function(dataAsJson) {
		var data = JSON.parse(dataAsJson);
		return this.loadData(data);
	},
	getSimpleState: function() {
		return this.tree.tree('getState');
	},
	getSimpleStateAsJson: function() {
		return JSON.stringify(this.getSimpleState());
	},
	loadSimpleState: function(state) {
		return this.tree.tree('setState', state);
	},
	loadSimpleStateAsJson: function(stateAsJson) {
		var state = JSON.parse(stateAsJson);
		return this.loadSimpleState(state);
	},
	onCreateLi: function(node, $li) 
	{
		var _this = this;
		var $title = $li.find('.jqtree-title');
		var auhorized_for_write = (!node['authorization'] || node['authorization'] == 'write')

		// Type
		if (_this.options.typeIconAttr && _this.options.typeIconAttr.length > 0) {
			var typeIcon = node[_this.options.typeIconAttr];
			if (!typeIcon) {
				typeIcon = 'file-o';
			}
			var type_icon_html = _this.options.typeIconTemplate.replace(':icon', typeIcon);
			$li.find('.jqtree-title').before(type_icon_html);
		}

		// Prepare actions
		var $actions = $('<div class="jqtree-actions"></div>');
		var actionsCount = 0;

		// Dropdown actions
		var dropdownActionsHtml = '';
		dropdownActionsHtml += '<div class="jqtree-other-actions">';
		dropdownActionsHtml += '	<div class="btn-group">';
		dropdownActionsHtml += '		<button type="button" class="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">';
		dropdownActionsHtml += '			<span class="caret"></span>';
		dropdownActionsHtml += '		</button>';
		dropdownActionsHtml += '		<ul class="dropdown-menu">';
		dropdownActionsHtml += '		</ul>';
		dropdownActionsHtml += '	</div>';
		dropdownActionsHtml += '</div>';
		var $dropdownActions = $(dropdownActionsHtml);
		var $dropdownActionsContainer = $dropdownActions.find('.dropdown-menu');
		var dropdownActionsCount = 0;

		// Create
		if (_this.options.create && auhorized_for_write) {
			var $createAction = null;
			if (_this.options.createActionCollapsed) {
				$createAction = $('<li><a href="#">' + _this.options.createIcon + '&nbsp;&nbsp;' + _this.options.createLabel + '</a></li>');
				$dropdownActionsContainer.append($createAction);
				dropdownActionsCount += 1;
			} else {
				$createAction = $('<div class="btn btn-primary btn-xs jqtree-create">' + _this.options.createIcon + '</div>');
				$actions.append($createAction);
				actionsCount += 1;
			}
			$createAction.click(function(e) {
				e.preventDefault();
				_this.appendNode(node.id);
			});
		}

		// Update
		if (_this.options.update && auhorized_for_write) {
			var $updateAction = null;
			if (_this.options.updateActionCollapsed) {
				$updateAction = $('<li><a href="#">' + _this.options.updateIcon + '&nbsp;&nbsp;' + _this.options.updateLabel + '</a></li>');
				$dropdownActionsContainer.append($updateAction);
				dropdownActionsCount += 1;
			} else {
				$updateAction = $('<div class="btn btn-primary btn-xs jqtree-update">' + _this.options.updateIcon + '</div>');
				$actions.append($updateAction);
				actionsCount += 1;
			}

			$title.editable({
				id: node.id,
				model: _this.options.model,
				column: 'name',
				updateUrl: _this.options.updateUrl.replace(':id', node.id),
				toggleElement: $updateAction,
				toggled: (node.new_record),
				onToggleIn: function() {
					_this.inEditation = true;
				},
				onToggleOut: function() {
					_this.inEditation = false;
				},
				onSuccess: function(newValue) {
					node.name = newValue;
					_this.saveState();
				}
			});
		}

		// Destroy
		if (_this.options.destroy && auhorized_for_write) {
			var $destroyAction = null;
			if (_this.options.destroyActionCollapsed) {
				$destroyAction = $('<li><a href="#">' + _this.options.destroyIcon + '&nbsp;&nbsp;' + _this.options.destroyLabel + '</a></li>');
				$dropdownActionsContainer.append($destroyAction);
				dropdownActionsCount += 1;
			} else {
				$destroyAction = $('<div class="btn btn-danger btn-xs jqtree-destroy">' + _this.options.destroyIcon + '</div>');
				$actions.append($destroyAction);
				actionsCount += 1;
			}
			$destroyAction.click(function(e) {
				e.preventDefault();
				alertify.confirm(_this.options.destroyConfirmMessage, '', function() { 
					_this.removeNode(node.id);
				}, function() { 
				});
			});
		}

		// User defined actions
		if (_this.options.actions && _this.options.actions.length > 0) {
			_this.options.actions.forEach(function(action) {
				var path = action.url.replace('%3Aid', node.id);
				$dropdownActionsContainer.append('<li><a href="' + path + '">' + _this.options.actionsIconTemplate.replace(':icon', action.icon) + '&nbsp;&nbsp;' + action.label + '</a></li>');
				dropdownActionsCount += 1;
			});
		}

		// Clipboard
		if (_this.options.clipboard) {
			var clipboardText = _this.options.clipboardTemplate;
			_this.options.clipboardAttrs.forEach(function(clipboard_attr) {
				clipboardText = clipboardText.replace(':' + clipboard_attr, node[clipboard_attr])
			});
			var clipboardHtml = '<div class="btn btn-default btn-xs jqtree-clipboard" data-clipboard-text="' + clipboardText + '">' + this.options.clipboardIcon + '</div>';
			$actions.append(clipboardHtml);
			actionsCount += 1;
		}

		// Dropdown actions
		if (dropdownActionsCount > 0) {
			$actions.append($dropdownActions);
			actionsCount += 1;
		}

		// Add actions after title
		$title.after($actions);
		$title.closest('.jqtree-element').css('padding-right', (actionsCount * 30) + 'px');

		// Style
		if (node['style']) {
			$title.closest('.jqtree-element').addClass('jqtree-element-' + node['style']);
		}

		// New record
		node.new_record = false
	},
	saveState: function() 
	{
		if (this.options.saveState == 'complex') {
			localStorage.setItem(this.storageKey + '_data', this.getDataAsJson());
			localStorage.setItem(this.storageKey + '_state', this.getSimpleStateAsJson());
		}
	},
	loadState: function()
	{
		if (this.options.saveState == 'complex') {
			var dataAsJson = localStorage.getItem(this.storageKey + '_data');
			if (dataAsJson) {
				this.loadDataAsJson(dataAsJson);
			}
		}
	},
	reloadState: function()
	{
		var _this = this;
		localStorage.removeItem(this.storageKey + '_data');
		this.tree.tree('reload', function() {
			// TODO Not working ...
			//var stateAsJson = localStorage.getItem(_this.storageKey + '_state');
			//_this.loadSimpleStateAsJson(stateAsJson);
		});
	},
	appendNode: function(parentNodeId)
	{
		var _this = this;
		var parentNode = _this.tree.tree('getNodeById', parentNodeId);
		_this.tree.tree('openNode', parentNode, false); // On Finish callback not working...
		
		var noName = 'No name';
		var data = {};
		data[_this.options.model] = {
			name: noName,
			parent_id: parentNodeId
		}
		
		// Create node in backend and get node data
		var createUrl = _this.options.createUrl;
		$.ajax({
			url: createUrl, 
			method: 'POST', 
			dataType: 'json',
			data: data,
			success: function(callback) {
				
				// Node data
				var nodeData = {
					name: noName,
					id: callback,
					new_record: true,
				}

				// Add node to tree
				if (parentNode.load_on_demand) {
					_this.tree.tree('appendNode', nodeData, parentNode);
				} else {
					_this.tree.tree('appendNode', nodeData, parentNode);
					_this.tree.tree('openNode', parentNode);
				}

				// State
				_this.saveState();

				// Message
				alertify.success(_this.options.createSuccessMessage); 
			}
		});
	},
	removeNode: function(nodeId)
	{
		var _this = this;
		
		// Remove in backend
		var destroyUrl = _this.options.destroyUrl.replace(':id', nodeId);
		$.ajax({
			url: destroyUrl, 
			method: 'DELETE', 
			dataType: 'json',
			success: function() {

				// Remove node from tree
				var node = _this.tree.tree('getNodeById', nodeId);
				_this.tree.tree('removeNode', node);

				// State
				_this.saveState();

				// Message
				alertify.success(_this.options.destroySuccessMessage); 
			}
		});
	},
	ready: function()
	{
		var _this = this;
		_this.tree = $('#tree-' + _this.hash);

		// Tree
		_this.tree.tree({
			dragAndDrop: _this.options.moving,
			saveState: (_this.options.saveState == 'simple' ? _this.storageKey + "_state" : null),
			closedIcon: $(_this.options.closedIcon),
			openedIcon: $(_this.options.openedIcon),
			onCreateLi: _this.onCreateLi.bind(_this),
		});

		// Init
		_this.tree.bind('tree.init', function() {
			
			// Load state
			_this.loadState()

			// Reload parent
			if (_this.options.parent) {
				eval('var parent = ' + _this.options.parent + ';');
				parent.reload();
			}
		});

		// Moving
		if (_this.options.moving == true) {
			_this.tree.bind('tree.move', function(event) {
				var relation = null;
				if (event.move_info.position.toString() == 'inside') {
					relation = 'child_first';
				} else if (event.move_info.position.toString() == 'after') {
					relation = 'right';
				} else if (event.move_info.position.toString() == 'before') {
					relation = 'left';
				}
				var moveUrl = _this.options.movingUrl.replace(':id', event.move_info.moved_node.id).replace(':relation', relation).replace(':destination_id', event.move_info.target_node.id);
				$.ajax({url: moveUrl, method: 'PUT', dataType: 'json'});

				// State
				_this.saveState();
			});
		}

		// Show
		if (_this.options.show == true) {
			_this.tree.bind('tree.' + _this.options.showEvent, function(event) {
				if (event.node && !_this.inEditation) {
					var node = event.node;
					var showUrl = _this.options.showUrl.replace(':id', event.node.id);
					if (typeof Turbolinks != "undefined") {
						Turbolinks.visit(showUrl);
					} else {
						window.location.href = showUrl;
					}
				}
			});
		}

		// Clipboard
		if (_this.options.clipboard) {
			new Clipboard('#tree-' + _this.hash + ' .jqtree-clipboard');
		}

		// Save state
		if (_this.options.saveState == 'complex') {
			_this.tree.bind('tree.open', function(event) {
				_this.saveState();
			});
			_this.tree.bind('tree.close', function(event) {
				_this.saveState();
			});
		}

		// Global actions prepare
		var $globalActions = $('<div class="jqtree-global-actions"></div>');
		var globalActionsCount = 0;

		// Reload
		if (_this.options.saveState == 'complex') {
			var $reloadAction = $('<div class="btn btn-default btn-xs jqtree-reload">' + _this.options.reloadIcon + '</div>');
			$reloadAction.click(function(e) {
				e.preventDefault();
				_this.reloadState();
			});
			$globalActions.append($reloadAction);
			globalActionsCount += 1;
		}

		// Global actions append
		if (globalActionsCount > 0) {
			_this.tree.before($globalActions);
		}
	},
	repair: function()
	{
		var _this = this;
		if (_this.options.clipboard) {
			new Clipboard('#tree-' + _this.hash + ' .jqtree-clipboard');
		}
	}
}