# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug tree builder
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class TreeBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
				@path_resolver = RugSupport::PathResolver.new(@template)
				@icon_builder = RugBuilder::IconBuilder
			end

			#
			# Render tree
			#
			# Options:
			# - actions (array) - which actions should be displayed for each node
			# - paths - paths to different actions (show, create, update, destroy, move)
			# - closed_icon (string) - icon to be used for closed node
			# - opened_icon (string) - icon to be used for open node
			# - type_icon_attr (string) - name of attribute containing type icon
			# - show_event (string) - use double_click or single_click for triggering show
			# - clipboard_attrs (array of string) - name/s of attribute/s used for clipboard save
			# - clipboard_template (string) - template used for constructing clipboard value (user :attr for substitution)
			# - clipboard_icon (string) - icon to be used for clipboard button
			# - save_state (:none, :simple, :complex) - which method should be used for state saving
			# - parent (string) - name of JavaScript variable implementing reload function which is called when tree is initialized
			#
			def tree(data_path, options = {})
				result = ""

				# Unique hash
				@hash = Digest::SHA1.hexdigest(data_path.to_s)

				# Options
				@options = options

				# Library JS
				result += @template.javascript_tag(%{
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

							// Type
							if (_this.options.typeIconAttr && _this.options.typeIconAttr.length > 0) {
								var typeIcon = node[_this.options.typeIconAttr];
								if (!typeIcon) {
									typeIcon = 'file-o';
								}
								var type_icon_html = '#{@icon_builder.render(":icon", class: "jqtree-icon")}'.replace(':icon', typeIcon);
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
							if (_this.options.create) {
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
							if (_this.options.update) {
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
							if (_this.options.destroy) {
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
									_this.removeNode(node.id);
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
										relation = 'child';
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
										window.location.href = showUrl;
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
						}
					}
				})

				# Clipboard
				if @options[:clipboard_attrs]
					clipboard = true
					@options[:clipboard_attrs] = [@options[:clipboard_attrs]] if !@options[:clipboard_attrs].is_a?(Array)
					clipboard_attrs_js = "[" + @options[:clipboard_attrs].map { |item| "'#{item}'" }.join(",") + "]"
				else
					clipboard = false
					clipboard_attrs_js = "[]"
				end

				# Actions
				if @options[:actions]
					actions_js = "["
					options[:actions].each do |key, action|
						actions_js += %{
							{
								url: '#{@path_resolver.resolve(action[:path], ":id")}',
								icon: '#{action[:icon]}',
								label: '#{action[:label]}',
							},
						}
					end
					actions_js += "]"
				else
					actions_js = "[]"
				end

				# Parent
				parent = (options[:parent] ? options[:parent] : nil)

				# Save state
				save_state = (options[:save_state] ? options[:save_state] : :simple)

				# Application JS
				result += @template.javascript_tag(%{
					var rug_tree_#{@hash} = null;
					$(document).ready(function() {
						rug_tree_#{@hash} = new RugTree('#{@hash}', {
							
							// Model
							model: 'node',

							// State
							saveState: '#{save_state.to_s}',

							// Parent element
							parent: '#{parent.to_s}',

							// Icons
							closedIcon: '#{@icon_builder.render(@options[:closed_icon] ? @options[:closed_icon] : "chevron-right")}',
							openedIcon: '#{@icon_builder.render(@options[:opened_icon] ? @options[:opened_icon] : "chevron-down")}',

							// Show
							show: #{check_show(@options) ? 'true' : 'false'},
							showEvent: '#{@options[:show_event] && @options[:show_event].to_sym == :double_click ? "dblclick" : "click"}',
							showUrl: '#{@path_resolver.resolve(@options[:paths][:show], ":id")}',

							// Create
							create: #{check_create(@options) ? 'true' : 'false'}, 
							createUrl: '#{@path_resolver.resolve(@options[:paths][:create])}',
							createIcon: '#{@icon_builder.render(@options[:update_icon] ? @options[:update_icon] : "plus")}',
							createLabel: '#{I18n.t("general.action.create_child").upcase_first}',
							createActionCollapsed: #{@options[:create_action_collapsed] == true ? 'true' : 'false'}, 

							// Update
							update: #{check_update(@options) ? 'true' : 'false'}, 
							updateUrl: '#{@path_resolver.resolve(@options[:paths][:update], ":id")}', 
							updateIcon: '#{@icon_builder.render(@options[:update_icon] ? @options[:update_icon] : "pencil")}',
							updateLabel: '#{I18n.t("general.action.update").upcase_first}',
							updateActionCollapsed: #{@options[:update_action_collapsed] == true ? 'true' : 'false'}, 

							// Destroy
							destroy: #{check_destroy(@options) ? 'true' : 'false'}, 
							destroyUrl: '#{@path_resolver.resolve(@options[:paths][:destroy], ":id")}', 
							destroyIcon: '#{@icon_builder.render(@options[:update_icon] ? @options[:update_icon] : "trash")}',
							destroyLabel: '#{I18n.t("general.action.destroy").upcase_first}',
							destroyActionCollapsed: #{@options[:destroy_action_collapsed] == true ? 'true' : 'false'}, 

							// Moving
							moving: #{check_moving(@options) ? 'true' : 'false'},
							movingUrl: '#{@path_resolver.resolve(@options[:paths][:move], ":id", ":relation", ":destination_id")}',
						
							// Type
							typeIconTemplate: '#{@icon_builder.render(":icon", class: "jqtree-icon")}',
							typeIconAttr: '#{@options[:type_icon_attr]}',

							// Actions
							actions: #{actions_js},
							actionsIconTemplate: '#{@icon_builder.render(":icon")}',

							// Clipboard
							clipboard: #{clipboard ? 'true' : 'false'},
							clipboardIcon: '#{@icon_builder.render(@options[:clipboard_icon] ? @options[:clipboard_icon] : "clipboard")}',
							clipboardTemplate: "#{clipboard ? (@options[:clipboard_template] ? @options[:clipboard_template].gsub('"', "'") : ":" + @options[:clipboard_attrs].first) : ""}",
							clipboardAttrs: #{clipboard_attrs_js},
							clipboardActionCollapsed: #{@options[:clipboard_action_collapsed] == true ? 'true' : 'false'}, 
						
							// Reload
							reloadIcon: '#{@icon_builder.render(@options[:update_icon] ? @options[:update_icon] : "refresh")}',
							reloadLabel: '#{I18n.t("general.action.reload").upcase_first}',
						});
						rug_tree_#{@hash}.ready();
					});
				})

				result += %{
					<div id="tree-#{@hash}" data-url="#{data_path.to_s}"></div>
				}

				return result.html_safe
			end

		protected

			def check_show(options)
				return options[:paths] && options[:paths][:show]
			end

			def check_create(options)
				return options[:paths] && options[:paths][:create]
			end

			def check_update(options)
				return options[:paths] && options[:paths][:update]
			end

			def check_destroy(options)
				return options[:paths] && options[:paths][:destroy]
			end

			def check_moving(options)
				result = true
				result = result && options[:moving] == true
				result = result && !options[:paths].blank?
				result = result && !options[:paths][:move].blank?
				return result
			end

		end
#	end
end
