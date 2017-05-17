# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - links
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class TableBuilder

		protected

			# *********************************************************************
			# Show
			# *********************************************************************

			def get_show_link(object, label, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return label
				end
				url = @path_resolver.resolve(path, object)
				if url
					label = I18n.t("general.action.show").upcase_first if label.blank?
					return (@template.link_to(label.html_safe, url, class: "link-show") + " ")
				else
					return label
				end
			end

			# *********************************************************************
			# New
			# *********************************************************************
			
			def get_new_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = @path_resolver.resolve(path)
				label = get_link_label(object, options, I18n.t("general.action.new").upcase_first)
				if url
					link_tag_options = {}
					link_tag_options[:class] = "link-new"
					if options[:disable_button] != true
						link_tag_options[:class] += " btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "primary"}"
					end
					return @template.link_to(@icon_builder.render(:new) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end

			# *********************************************************************
			# Edit
			# *********************************************************************
			
			def get_edit_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = @path_resolver.resolve(path, object)
				label = get_link_label(object, options, I18n.t("general.action.edit").upcase_first)
				if url
					link_tag_options = {}
					link_tag_options[:class] = "link-edit"
					if options[:disable_button] != true
						link_tag_options[:class] += " btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "primary"}"
					end
					return @template.link_to(@icon_builder.render(:edit) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end
			
			# *********************************************************************
			# Create
			# *********************************************************************

			def get_create_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = @path_resolver.resolve(path)
				label = get_link_label(object, options, I18n.t("general.action.create").upcase_first)
				if url
					link_tag_options = {}
					link_tag_options[:class] = "link-create"
					if options[:disable_button] != true
						link_tag_options[:class] += " btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "primary"}"
					end
					return @template.link_to(@icon_builder.render(:new) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end

			# *********************************************************************
			# Destroy
			# *********************************************************************

			def get_destroy_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = @path_resolver.resolve(path, object)
				label = get_link_label(object, options, I18n.t("general.action.destroy").upcase_first)
				if url
					link_tag_options = {}
					link_tag_options[:class] = "link-destroy"
					if !check_inline_destroy(@options) # If inline destroy enabled, method and confirm cannot be set because it activates jquery_ujs handling which breaks destroyable...
						if options[:disable_method_and_notification] != true
							link_tag_options[:method] = :delete
							link_tag_options[:data] = { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") }
						end
					end
					if options[:disable_button] != true
						link_tag_options[:class] += " btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "danger"}"
					end
					return @template.link_to(@icon_builder.render(:destroy) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end

			def get_inline_destroy_data(object, path, options = {})
				result = ""
				result += "data-destroy-url=\"#{@path_resolver.resolve(path, object)}\" "
				result += "data-destroy=\"a.link-destroy\" "
				return result
			end

			# *********************************************************************
			# Common actions
			# *********************************************************************

			def get_action_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = @path_resolver.resolve(path, object)
				label = get_link_label(object, options)
				if url
					link_tag_options = {}
					link_tag_options[:class] = "btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"}"
					link_tag_options[:method] = options[:method] if options[:method]
					return @template.link_to(@icon_builder.render(options[:icon]) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end

			# *********************************************************************
			# Common actions
			# *********************************************************************

			def get_moving_link(options = {})
				link_tag_options = {}
				link_tag_options[:class] = "moving-handle btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"}"
				return @template.link_to(@icon_builder.render(options[:icon] ? options[:icon] : :move) + options[:label].to_s, "#", link_tag_options) + " "
			end

			def get_moving_up_link(object, path, options = {})
				url = @path_resolver.resolve(path, object)
				link_tag_options = {}
				link_tag_options[:class] = "btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"}"
				link_tag_options[:method] = options[:method] ? options[:method] : "put"
				return @template.link_to(@icon_builder.render(options[:icon] ? options[:icon] : :move_up) + options[:label].to_s, url, link_tag_options) + " "
			end

			def get_moving_down_link(object, path, options = {})
				url = @path_resolver.resolve(path, object)
				link_tag_options = {}
				link_tag_options[:class] = "btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"}"
				link_tag_options[:method] = options[:method] ? options[:method] : "put"
				return @template.link_to(@icon_builder.render(options[:icon] ? options[:icon] : :move_down) + options[:label].to_s, url, link_tag_options) + " "
			end

			# *********************************************************************
			# Label
			# *********************************************************************

			def get_link_label(object, options, default = "")
				if !options[:label].nil?
					if options[:label] != false
						if options[:label].is_a?(Proc)
							return options[:label].call(object)
						else
							return options[:label]
						end
					else
						return ""
					end
				else
					return default
				end
			end

		end
#	end
end