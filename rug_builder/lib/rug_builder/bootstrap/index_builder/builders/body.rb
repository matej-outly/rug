# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug index builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

require "rug_builder/bootstrap/index_builder/builders/layout/table"
require "rug_builder/bootstrap/index_builder/builders/layout/thumbnails"
require "rug_builder/bootstrap/index_builder/builders/layout/list"

module RugBuilder
#module Bootstrap
	class IndexBuilder
		module Builders
			class Body
				include RugBuilder::IndexBuilder::Concerns::Utils
				include RugBuilder::IndexBuilder::Concerns::Partial
				include RugBuilder::Concerns::Columns
				include RugBuilder::Concerns::Actions
				include RugBuilder::Concerns::Brs
				include RugBuilder::Concerns::Builders

				def initialize(template)
					@template = template
				end

				# *************************************************************
				# Render
				# *************************************************************

				def render(objects, options = {}, &block)
					
					# Save
					@objects = objects
					@options = options
					@block = block

					# Clear
					self.clear
					self.clear_columns
					self.clear_actions

					# Render entire body
					result = ""
					if @options[:layout].to_s == "thumbnails"
						result += render_as_thumbnails(objects)
					elsif @options[:layout].to_s == "list"
						result += render_as_list(objects)
					else
						result += render_as_table(objects)
					end
					result += render_actions_modals

					# Render body or partial
					if @options[:partial] == true
						return self.render_partial
					else
						return result.html_safe
					end
				end

				#
				# Markup:
				# - container_selector
				# - item_selector
				# - item_path
				# - move_placeholder
				#
				def render_js(markup)
					
					if @movable
						movable_js = %{
							movable: {
								placeholder: '#{markup[:move_placeholder].to_s}',
								url: '#{self.path_resolver.resolve(@movable[:path], ":id", ":relation", ":destination_id")}',
							},
						}
					else
						movable_js = ""
					end

					if @destroyable
						destroyable_js = %{
							destroyable: {
								confirmTitle: '#{I18n.t("general.are_you_sure")}',
								confirmMessage: '#{I18n.t("general.are_you_sure_explanation")}',
								successMessage: '#{I18n.t("general.messages.destroy.success")}',
								errorMessage: '#{I18n.t("general.messages.destroy.error")}',
							},
						}
					else
						destroyable_js = ""
					end

					if @sortable
						sortable_js = %{
							sortable: true,
						}
					else
						sortable_js = ""
					end

					if @options[:reload_path]
						reloadable_js = %{
							reloadable: {
								url: '#{self.path_resolver.resolve(@options[:reload_path], ":id").gsub("%3A", ":")}',
							},
						}
					else
						reloadable_js = ""
					end

					if @options[:paginate_path]
						paginateable_js = %{
							paginateable: {
								url: '#{self.path_resolver.resolve(@options[:paginate_path], page: ":page").gsub("%3A", ":")}',
							},
						}
					else
						paginateable_js = ""
					end

					if @options[:layout] == :thumbnails && @options[:thumbnails_tiles]
						tilable_js = %{
							tilable: true,
						}
					else
						tilable_js = ""
					end

					js = %{
						var #{self.js_object} = null;
						$(document).ready(function() {
							#{self.js_object} = new RugIndex('#{self.hash}', {
								containerSelector: '#{markup[:container_selector].to_s}',
								itemPath:          '#{markup[:item_path].to_s}',
								itemSelector:      '#{markup[:item_selector].to_s}',
								addPosition:       '#{@options[:add_position] ? @options[:add_position].to_s : "append"}',
								#{reloadable_js}
								#{paginateable_js}
								#{movable_js}
								#{destroyable_js}
								#{sortable_js}
								#{tilable_js}
							});
							#{self.js_object}.ready();
						});
					}
					return js
				end

			protected

				# *************************************************************
				# Internal structures
				# *************************************************************

				def clear
					@verticals = nil
					@sorts = nil
					@shows = nil
					@movable = nil
					@destroyable = nil
					@sortable = nil
					@showable = nil
				end

				def verticals
					@verticals = [[]] if @verticals.nil?
					return @verticals
				end

				def current_vertical
					@verticals = [[]] if @verticals.nil?
					return @verticals.last
				end

				def sorts
					@sorts = {} if @sorts.nil?
					return @sorts
				end

				def shows
					@shows = {} if @shows.nil?
					return @shows
				end

				def add_column(column, options)
					self.current_vertical << { type: :column, column: column.to_sym }
					if options[:sort] && options[:sort] != false
						self.sorts[column.to_sym] = options[:sort]
						@sortable = true
					end
					if options[:show] && options[:show] != false
						self.shows[column.to_sym] = options[:show]
						@showable = true
					end
				end

				def add_action(action, options)
					self.current_vertical << { type: :action, action: action.to_sym }
					
					# Movable
					if action.to_sym == :move
						@movable = {
							path: self.actions[:move][:path] # Save mave path for JS handling
						}
						self.actions[:move][:path] = nil # Move handle has no URL
						self.actions[:move][:class] = "move-handle" # Necessary for JS to work
					end

					# Destroyable
					if action.to_sym == :destroy && options[:ajax] == true
						@destroyable = {
							path: self.actions[:destroy][:path] # Save mave path for JS handling
						}
						self.actions[:destroy][:path] = nil # Destroy handle has no URL
						self.actions[:destroy][:data] = nil # Destroy handle has no data
						self.actions[:destroy][:method] = nil # Destroy handle has no method
					end
				end

				def add_br(options)
					if @verticals.nil?
						@verticals = [[]] 
					else
						@verticals << [] # Add new vertical
					end
				end

				# *************************************************************
				# HTML data builders
				# *************************************************************

				def destroyable_data(object)
					result = ""
					result += "data-destroy-url=\"#{self.path_resolver.resolve(@destroyable[:path], object)}\" "
					result += "data-destroy=\"a.link-destroy\" "
					return result
				end

			end
		end
	end
#end
end