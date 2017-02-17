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
			# - paths - paths to different actions
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
					}
					RugTree.prototype = {
						constructor: RugTree,
						onCreateLi: function(node, $li) 
						{
							var _this = this;

							// Type
							if (_this.options.typeIconAttr && _this.options.typeIconAttr.length > 0) {
								var typeIcon = node[_this.options.typeIconAttr];
								if (!typeIcon) {
									typeIcon = 'file-o';
								}
								var type_icon_html = '#{@icon_builder.render(":icon", class: "jqtree-icon")}'.replace(':icon', typeIcon);
								$li.find('.jqtree-title').before(type_icon_html);
							}

							// Actions
							if (_this.options.actions && _this.options.actions.length > 0) {
								var actionsHtml = '';
								actionsHtml += '<div class="jqtree-actions">';
								actionsHtml += '	<div class="btn-group">';
								actionsHtml += '		<button type="button" class="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">';
								actionsHtml += '			<span class="caret"></span>';
								actionsHtml += '		</button>';
								actionsHtml += '		<ul class="dropdown-menu">';
								_this.options.actions.forEach(function(action) {
									var path = action.url.replace('%3Aid', node.id);
									actionsHtml += '			<li><a href="' + path + '">' + _this.options.actionsIconTemplate.replace(':icon', action.icon) + '&nbsp;&nbsp;' + action.label + '</a></li>';
								});
								actionsHtml += '		</ul>';
								actionsHtml += '	</div>';
								actionsHtml += '</div>';
								$li.find('.jqtree-title').after(actionsHtml);
							}

							// Clipboard
							if (_this.options.clipboard) {
								var clipboardText = _this.options.clipboardTemplate;
								_this.options.clipboardAttrs.forEach(function(clipboard_attr) {
									clipboardText = clipboardText.replace(':' + clipboard_attr, node[clipboard_attr])
								});
								var clipboardHtml = '<div class="btn btn-default btn-xs jqtree-clipboard" data-clipboard-text="' + clipboardText + '">' + this.options.clipboardIcon + '</div>';
								$li.find('.jqtree-title').after(clipboardHtml);
							}
						},
						getData: function() {
							return this.tree.tree('getTree').getData();
						},
						loadData: function(data) {
							return this.tree.tree('loadData', data);
						},
						getJson: function() {
							return this.tree.tree('toJson');
						},
						loadJson: function(dataAsJson) {
							var data = JSON.parse(dataAsJson);
							return this.loadData(data);
						},
						ready: function()
						{
							var _this = this;
							_this.tree = $('#tree-' + _this.hash);

							_this.tree.tree({
								dragAndDrop: _this.options.moving,
								saveState: (_this.options.saveState == 'simple' ? _this.storageKey : null),
								closedIcon: $(_this.options.closedIcon),
								openedIcon: $(_this.options.openedIcon),
								onCreateLi: _this.onCreateLi.bind(_this),
							});

							_this.tree.bind('tree.init', function() {
								
								// Save state
								if (_this.options.saveState == 'complex') {
									var dataAsJson = localStorage.getItem(_this.storageKey);
									if (dataAsJson) {
										_this.loadJson(dataAsJson);
									}
								}

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

									// Save state
									if (_this.options.saveState == 'complex') {
										localStorage.setItem(_this.storageKey, _this.getJson());
									}
								});
							}

							// Show
							if (_this.options.show == true) {
								_this.tree.bind('tree.' + _this.options.showEvent, function(event) {
									if (event.node) {
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
									localStorage.setItem(_this.storageKey, _this.getJson());
								});
								_this.tree.bind('tree.close', function(event) {
									localStorage.setItem(_this.storageKey, _this.getJson());
								});
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
					actions_js += "[]"
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
							
							// State
							saveState: '#{save_state.to_s}',

							// Parent element
							parent: '#{parent.to_s}',

							// Icons
							closedIcon: '#{@icon_builder.render(@options[:closed_icon] ? @options[:closed_icon] : "chevron-right")}',
							openedIcon: '#{@icon_builder.render(@options[:opened_icon] ? @options[:opened_icon] : "chevron-down")}',
							
							// Moving
							moving: #{check_moving(@options) ? 'true' : 'false'},
							movingUrl: '#{@path_resolver.resolve(@options[:paths][:move], ":id", ":relation", ":destination_id")}',
						
							// Show
							show: #{check_show(@options) ? 'true' : 'false'},
							showEvent: '#{@options[:show_event] && @options[:show_event].to_sym == :double_click ? "dblclick" : "click"}',
							showUrl: '#{@path_resolver.resolve(@options[:paths][:show], ":id")}',

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
