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
			# - global_actions (hash) - Define custom global actions as combination of path, method, icon, label and show_if condition
			#
			def show(object, columns, options = {})
				result = ""

				# Check
				if object.nil?
					raise "Given object is nil."
				end

				# Normalize columns to Columns object
				columns = normalize_columns(columns)

				# Show panel parts
				show_panel_heading = check_new_link(options) || check_edit_link(options) || check_destroy_link(options) || options[:actions]

				# Panel
				result += "<div class=\"panel panel-default\">"

				# Panel heading
				result += "<div class=\"panel-heading\">" if show_panel_heading

				# Actions
				if options[:actions]
					options[:actions].each do |action, action_spec|
						action_spec[:size] = "sm" if action_spec[:size].nil?
						result += get_action_link(object, action_spec[:path], action_spec)
					end
				end

				# Standard actions
				result += get_new_link(options[:paths][:new], size: "sm") if check_new_link(options)
				result += get_edit_link(object, options[:paths][:edit], size: "sm") if check_edit_link(options)
				result += get_destroy_link(object, options[:paths][:destroy], size: "sm") if check_destroy_link(options)

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