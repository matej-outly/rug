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
				@options = options.nil? ? {} : options

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
							createSuccessMessage: '#{I18n.t("general.messages.create.success")}',

							// Update
							update: #{check_update(@options) ? 'true' : 'false'}, 
							updateUrl: '#{@path_resolver.resolve(@options[:paths][:update], ":id")}', 
							updateIcon: '#{@icon_builder.render(@options[:update_icon] ? @options[:update_icon] : "pencil")}',
							updateLabel: '#{I18n.t("general.action.update").upcase_first}',
							updateActionCollapsed: #{@options[:update_action_collapsed] == true ? 'true' : 'false'}, 
							updateSuccessMessage: '#{I18n.t("general.messages.create.success")}',

							// Destroy
							destroy: #{check_destroy(@options) ? 'true' : 'false'}, 
							destroyUrl: '#{@path_resolver.resolve(@options[:paths][:destroy], ":id")}', 
							destroyIcon: '#{@icon_builder.render(@options[:update_icon] ? @options[:update_icon] : "trash")}',
							destroyLabel: '#{I18n.t("general.action.destroy").upcase_first}',
							destroyActionCollapsed: #{@options[:destroy_action_collapsed] == true ? 'true' : 'false'}, 
							destroyConfirmMessage: '#{I18n.t("general.are_you_sure")}',
							destroySuccessMessage: '#{I18n.t("general.messages.destroy.success")}',

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
					$(document).on('turbolinks:load', function() {
						rug_tree_#{@hash}.repair();
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
