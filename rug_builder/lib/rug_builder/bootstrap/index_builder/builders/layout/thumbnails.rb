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

module RugBuilder
#module Bootstrap
	class IndexBuilder
		module Builders
			class Body

				def render_as_thumbnails(objects)
					
					# Capture all columns and actions
					unused = @template.capture(self, &@block) 

					# Render
					empty_message = %{<div class="empty-message">#{I18n.t("views.index.empty")}</div>}
					result = %{
						<div 
							id="#{self.id}" 
							class="list #{self.css_class}-body row #{@movable ? "movable" : ""} #{@options[:class].to_s}"
						>
							#{objects.empty? ? empty_message : ""}
							#{render_thumbnails(objects)}
						</div>
					}

					# Render JS
					result += @template.javascript_tag(render_js(
						container_selector: ".list",
						item_selector: ".item",
						move_placeholder: render_thumbnail_placeholder
					))

					return result.html_safe
				end

				def render_thumbnails(objects)
					result = ""
					objects.each do |object| 
						result += self.capture_partial(render_thumbnail(object)) + "\n"
					end
					return result.html_safe
				end

				def render_thumbnail(object)
					
					# Grid
					col_xs, col_sm, col_md = self.thumbnails_grid
					
					result = ""
					result += %{<div 
						class="item col-xs-#{col_xs} col-sm-#{col_sm} col-md-#{col_md} #{@destroyable ? "destroyable" : ""}" 
						data-id=\"#{object.id}\" 
						#{@destroyable ? self.destroyable_data(object) : ""}
					>}
					
					# Moving handle
					result += self.render_action_link(:move, object: object, size: "sm", default_label: false) if @movable

					result += %{<div class="thumbnail">}
					
					# Thumbnail (first column)
					result += %{<span class="thumbnail-crop thumbnail-crop-horizontal" style="height: #{@options[:thumbnails_crop]}px; width: 100%;">} if @options[:thumbnails_crop]
					if !self.columns.empty?
						first_column = self.columns.keys.first
						value = self.render_column_value(first_column, object).to_s 
						if self.shows[first_column]
							result += self.render_link(self.shows[first_column].merge(
								label: value,
								fallback: value, 
								object: object, 
								disable_button: true, 
							))
						elsif self.columns[first_column][:action]
							result += self.render_link(self.columns[first_column][:action].merge(
								label: value,
								fallback: value, 
								object: object, 
								disable_button: true, 
							))
						else
							result += value
						end
					end
					result += %{</span>} if @options[:thumbnails_crop]

					# Caption (other columns)
					caption_html = ""
					self.columns.keys[1..-1].each_with_index do |column, index|
						value = self.render_column_value(column, object).to_s
						if self.shows[column]
							value = self.render_link(self.shows[column].merge(
								label: value,
								fallback: value, 
								default_label: "...",
								object: object, 
								disable_button: true, 
							))
						end
						if !value.blank?
							if index == 0 
								caption_html += %{<h5>#{value}</h5>}
							else
								caption_html += value
							end
						end
					end
					result += %{<div class="caption inner-box">#{caption_html}</div>} if !caption_html.blank?
					
					# Actions
					actions_html = ""
					self.actions.keys.reject{ |action| action == :move }.each do |action|
						actions_html += self.render_action_link(action, object: object, size: "sm", default_label: false) + " "
					end
					result += %{<div class="actions">#{actions_html}</div>} if !actions_html.blank?
					
					result += %{</div>}
					result += %{</div>}

					return result.html_safe
				end

				def render_thumbnail_placeholder
					col_xs, col_sm, col_md = self.thumbnails_grid
					%{<div class="placeholder col-xs-#{col_xs} col-sm-#{col_sm} col-md-#{col_md}"></div>}
				end

			protected

				def thumbnails_grid
					case (@options[:thumbnails_grid] ? @options[:thumbnails_grid] : 3)
					when 1
						col_xs = 12
						col_sm = 12
						col_md = 12
					when 2
						col_xs = 6
						col_sm = 6
						col_md = 6
					when 3
						col_xs = 6
						col_sm = 6
						col_md = 4
					when 4
						col_xs = 4
						col_sm = 4
						col_md = 3
					when 5
						col_xs = 4
						col_sm = 4
						col_md = 3
					when 6
						col_xs = 4
						col_sm = 4
						col_md = 2
					else
						col_xs = 6
						col_sm = 6
						col_md = 4
					end
					return [col_xs, col_sm, col_md]
				end

			end
		end
	end
end