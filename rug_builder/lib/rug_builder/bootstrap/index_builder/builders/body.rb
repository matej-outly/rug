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

module RugBuilder
#module Bootstrap
	class IndexBuilder
		module Builders
			class Body
				include RugBuilder::IndexBuilder::Concerns::Utils
				include RugBuilder::Concerns::Columns
				include RugBuilder::Concerns::Actions

				def initialize(template)
					@template = template
					@path_resolver = RugSupport::PathResolver.new(@template)
					@icon_builder = RugBuilder::IconBuilder
				end

				# *************************************************************
				# Render
				# *************************************************************

				def render(objects, options = {}, &block)
					
					# Save
					@objects = objects
					@options = options

					# Clear
					self.clear
					self.clear_columns
					self.clear_actions

					# Capture all columns and actions
					unused = @template.capture(self, &block) 

					if objects.empty?
						result = %{
							<div class="#{self.css_class}-body empty empty-message #{@options[:class].to_s}">
								#{I18n.t("views.index_table.empty")}
							</div>
						}
					else
						if @options[:layout] == :thumbnails
							result = render_as_thumbnails(objects)
						else
							result = render_as_table(objects)
						end
					end

					return result.html_safe
				end

				#
				# Markup:
				# - container_selector
				# - item_selector
				# - item_selector_path
				# - item_template
				# - moving_placeholder
				#
				def render_js(markup)
					js = %{
						var #{self.js_object} = null;
						$(document).ready(function() {
							#{self.js_object} = new RugTable('#{self.hash}', {
								
								// Common
								containerSelector: '#{markup[:container_selector].to_s}',
								itemSelectorPath: '#{markup[:item_selector_path].to_s}',
								itemSelector: '#{markup[:item_selector].to_s}',
								itemTemplate: `
									#{markup[:item_template].to_s}
								`,

								// Moving
								moving: #{@moving ? "true" : "false"},
								movingPlaceholder: '#{markup[:moving_placeholder].to_s}',
								
								// Destroyable
								destroyable: #{@destroyable ? "true" : "false"},
								destroyableConfirmTitle: '#{I18n.t("general.are_you_sure")}',
								destroyableConfirmMessage: '#{I18n.t("general.are_you_sure_explanation")}',
								destroyableSuccessMessage: '#{I18n.t("general.action.messages.destroy.success")}',
								destroyableErrorMessage: '#{I18n.t("general.action.messages.destroy.error")}',

								// Tiles
								tiles: #{@options[:thumbnails_tiles] ? "true" : "false"},
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
					@moving = nil
					@destroyable = nil
				end

				def verticals
					@verticals = [] if @verticals.nil?
					return @verticals
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
					self.verticals << { type: :column, column: column.to_sym }
					if options[:sort]
						self.sorts[column.to_sym] = true
					end
					if options[:show]
						self.shows[column.to_sym] = options[:show]
					end
				end

				def add_action(action, options)
					self.verticals << { type: :action, action: action.to_sym }
					
					# Moving
					if action.to_sym == :move
						@moving = {
							path: self.actions[:move][:path] # Save mave path for JS handling
						}
						self.actions[:move][:path] = nil # Moving handle has no URL
						self.actions[:move][:class] = "moving-handle" # Necessary nof JS to work
					end

					# Destroyable
					if action.to_sym == :destroy && options[:ajax] == true
						@destroyable = {
							path: self.actions[:destroy][:path] # Save mave path for JS handling
						}
						self.actions[:destroy][:path] = nil # Moving handle has no URL
					end
				end

				# *************************************************************
				# HTML data builders
				# *************************************************************

				def destroyable_data(object)
					result = ""
					result += "data-destroy-url=\"#{@path_resolver.resolve(@destroyable[:path], object)}\" "
					result += "data-destroy=\"a.link-destroy\" "
					return result
				end

				def moving_data
					result = ""
					result += "data-move-url=\"#{@path_resolver.resolve(@moving[:path], ":id", ":relation", ":destination_id")}\" "
					return result
				end

			end
		end
	end
#end
end