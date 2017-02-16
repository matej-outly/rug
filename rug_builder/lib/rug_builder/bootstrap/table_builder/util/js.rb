# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - JavaScript
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class TableBuilder

		protected

			def js_library
				js = %{
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
						inlineDestroyReady()
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
				}

				return js
			end

			#
			# Markup:
			# - container_selector
			# - item_selector
			# - item_selector_path
			# - item_template
			# - moving_placeholder
			#
			def js_application(markup)
				js = %{
					var rug_table_#{@hash} = null;
					$(document).ready(function() {
						rug_table_#{@hash} = new RugTable('#{@hash}', {
							
							// Common
							containerSelector: '#{markup[:container_selector].to_s}',
							itemSelectorPath: '#{markup[:item_selector_path].to_s}',
							itemSelector: '#{markup[:item_selector].to_s}',
							itemTemplate: `
								#{markup[:item_template].to_s}
							`,

							// Moving
							moving: #{check_moving(@options) ? 'true' : 'false' },
							movingPlaceholder: '#{markup[:moving_placeholder].to_s}',
							movingUrl: '#{check_moving(@options) && @path_resolver.resolve(@options[:paths][:move], ":id", ":relation", ":destination_id")}',

							// Inline destroy
							inlineDestroy: #{check_inline_destroy(@options) ? 'true' : 'false'},
							inlineDestroyConfirmTitle: '#{I18n.t("general.are_you_sure")}',
							inlineDestroyConfirmMessage: '#{I18n.t("general.are_you_sure_explanation")}',
							inlineDestroySuccessMessage: '#{I18n.t("general.action.messages.destroy.success")}',
							inlineDestroyErrorMessage: '#{I18n.t("general.action.messages.destroy.error")}',

						});
						rug_table_#{@hash}.ready();
					});
				}
				return js
			end

		end
	#end
end