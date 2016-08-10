# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - show
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class TableBuilder

			#
			# Render show table
			#
			# Options:
			# - show_blank_rows (boolean) - Turn on rows without any content
			# - paths (hash) - Define paths to new, edit and destroy actions
			# - actions (hash) - Define custom global actions as combination of path, method, icon, label and show_if condition
			#
			def show(object, columns, options = {})
				result = ""

				# Check
				if object.nil?
					raise "Given object is nil."
				end

				# Normalize columns to Columns object
				columns = normalize_columns(columns)

				# Prepare global actions
				actions = {}
				if options[:actions]
					options[:actions].each do |action, action_spec|
						action_spec[:size] = "sm" if action_spec[:size].nil?
						if action == :new
							actions[:new] = {
								block: lambda { |object| get_new_link(object, action_spec[:path], action_spec) }
							}
						elsif action == :edit
							actions[:edit] = {
								block: lambda { |object| get_edit_link(object, action_spec[:path], action_spec) }
							}
						elsif action == :destroy
							actions[:destroy] = {
								block: lambda { |object| get_destroy_link(object, action_spec[:path], action_spec) }
							}
						else
							actions[action] = {
								block: lambda { |object| get_action_link(object, action_spec[:path], action_spec) }
							}
						end
					end
				end
				if (options[:actions].nil? || options[:actions][:new].nil?) && check_new_link(options) # Automatic NEW action
					actions[:new] = {
						block: lambda { |object| get_new_link(options[:paths][:new], size: "sm") }
					}
				end
				if (options[:actions].nil? || options[:actions][:edit].nil?) && check_edit_link(options) # Automatic EDIT action
					actions[:edit] = {
						block: lambda { |object| get_edit_link(object, options[:paths][:edit], size: "sm") }
					}
				end
				if (options[:actions].nil? || options[:actions][:destroy].nil?) && check_destroy_link(options) # Automatic DESTROY action
					actions[:destroy] = {
						block: lambda { |object| get_destroy_link(object, options[:paths][:destroy], size: "sm") }
					}
				end

				# Show panel parts
				show_panel_heading = !actions.empty?

				# Panel
				result += "<div class=\"panel panel-default\">"

				# Panel heading
				result += "<div class=\"panel-heading\">" if show_panel_heading

				# Actions
				if actions
					actions.each do |action, action_spec|
						result += action_spec[:block].call(object)
					end
				end
				
				# Panel heading
				result += "</div>" if show_panel_heading

				# Table
				result += "<table class=\"table show-table #{options[:class].to_s}\">"

				# Table body
				result += "<tbody>"
				columns.headers.each do |column|
					value = columns.render(column, object)
					if options[:show_blank_rows] == true || !value.blank?
						result += "<tr>"
						result += "<td>#{columns.label(column, object.class)}</td>"
						result += "<td>#{value}</td>"
						result += "</tr>"
					end
				end
				result += "</tbody>"

				# Table
				result += "</table>"
				result += "</div>"

				return result.html_safe
			end
			
		end
#	end
end