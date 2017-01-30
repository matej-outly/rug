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
			def tree(data_path, options = {})
				result = ""

				# Unique hash
				hash = Digest::SHA1.hexdigest(data_path.to_s)

				# Moving
				if check_moving(options)
					moving_js = %{
						$('#tree_#{hash}').bind('tree.move', function(event) {
							var relation = null;
							if (event.move_info.position.toString() == 'inside') {
								relation = 'child';
							} else if (event.move_info.position.toString() == 'after') {
								relation = 'right';
							} else if (event.move_info.position.toString() == 'before') {
								relation = 'left';
							}
							var move_url = '#{@path_resolver.resolve(options[:paths][:move], ":id", ":relation", ":destination_id")}'.replace(':id', event.move_info.moved_node.id).replace(':relation', relation).replace(':destination_id', event.move_info.target_node.id);
							$.ajax({url: move_url, method: 'PUT', dataType: 'json'});
						});
					}
				end

				# Show
				if check_show_link(options)
					event = (options[:show_event] && options[:show_event].to_sym == :double_click ? "dblclick" : "click")
					show_js = %{
						$('#tree_#{hash}').bind('tree.#{event}', function(event) {
							if (event.node) {
								var node = event.node;
								var show_url = '#{@path_resolver.resolve(options[:paths][:show], ":id")}'.replace(':id', event.node.id);
								window.location.href = show_url;
							}
						});
					}
				end

				# Actions
				if options[:actions]
					actions_js = ""
					actions_js += "var actions_html = '';\n"
					actions_js += "actions_html += '<div class=\"jqtree-actions\">';\n"
					actions_js += "actions_html += '	<div class=\"btn-group\">';\n"
					actions_js += "actions_html += '		<button type=\"button\" class=\"btn btn-default btn-xs dropdown-toggle\" data-toggle=\"dropdown\" aria-haspopup=\"true\" aria-expanded=\"false\">';\n"
					actions_js += "actions_html += '			<span class=\"caret\"></span>';\n"
					actions_js += "actions_html += '		</button>';\n"
					actions_js += "actions_html += '		<ul class=\"dropdown-menu dropdown-menu-right\">';\n"
					actions_js += "var path = null;\n"
					options[:actions].each do |key, action|
						actions_js += "path = '#{@path_resolver.resolve(action[:path], ":id")}'.replace('%3Aid', node.id);\n"
						actions_js += "actions_html += '			<li><a href=\"' + path + '\">#{@icon_builder.render(action[:icon])}&nbsp;&nbsp;#{action[:label]}</a></li>';\n"
					end
					actions_js += "actions_html += '		</ul>';\n"
					actions_js += "actions_html += '	</div>';\n"
					actions_js += "actions_html += '</div>';\n"
					actions_js += "$li.find('.jqtree-title').after(actions_html);\n"
				end

				# Icon
				if options[:type_icon]
					icon_js = %{
						var icon = node.#{options[:type_icon]}
						if (!icon) {
							icon = 'file-o';
						}
						var icon_html = '#{@icon_builder.render(":icon", class: "jqtree-icon")}'.replace(':icon', icon);
						$li.find('.jqtree-title').before(icon_html);
					}
				end

				# Clipboard
				if options[:clipboard]
					clipboard_text_js = "node.#{options[:clipboard]}"
					if options[:clipboard_label]
						clipboard_text_js = "<a href='\" + #{clipboard_text_js} + \"'>\" + node.#{options[:clipboard_label]} + \"</a>"
					end

					clipboard_js = %{
						var clipboard_html = "<div class=\\\"btn btn-default btn-xs jqtree-clipboard\\\" data-clipboard-text=\\\"#{clipboard_text_js}\\\">#{@icon_builder.render(options[:clipboard_icon] ? options[:clipboard_icon] : "clipboard").gsub('"', '\"')}</div>";
						$li.find('.jqtree-title').after(clipboard_html);
					}
					enable_clipboard_js = %{
					    new Clipboard('#tree_#{hash} .jqtree-clipboard');
					}
				end

				js = %{
					function tree_#{hash}_ready()
					{
						$('#tree_#{hash}').tree({
							#{check_moving(options) ? "dragAndDrop: true," : ""}
							saveState: true,
							closedIcon: $('#{@icon_builder.render(options[:closed_icon] ? options[:closed_icon] : "chevron-right")}'),
							openedIcon: $('#{@icon_builder.render(options[:opened_icon] ? options[:opened_icon] : "chevron-down")}'),
							onCreateLi: function(node, $li) {
								#{icon_js && icon_js}
								#{actions_js && actions_js}
								#{clipboard_js && clipboard_js}
							}
						});
						#{check_show_link(options) && show_js}
						#{check_moving(options) && moving_js}
						#{enable_clipboard_js && enable_clipboard_js}
					}
					$(document).ready(tree_#{hash}_ready);
				}
				result += @template.javascript_tag(js)

				result += %{<div id="tree_#{hash}" data-url="#{data_path.to_s}"></div>}

				return result.html_safe
			end

		protected

			def check_show_link(options)
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
