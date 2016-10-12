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

			def check_show_link(options)
				return options[:paths] && options[:paths][:show]
			end

			def get_show_link(object, label, path, options = {})
				url = RugSupport::PathResolver.new(@template).resolve(path, object)
				if url
					label = I18n.t("general.action.show").upcase_first if label.blank?
					return @template.link_to(label, url) + " "
				else
					return label
				end
			end

			# *********************************************************************
			# New
			# *********************************************************************
			
			def check_new_link(options)
				return options[:paths] && options[:paths][:new]
			end

			def get_new_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = RugSupport::PathResolver.new(@template).resolve(path)
				if !options[:label].nil?
					if options[:label] != false
						label = options[:label]
					else
						label = ""
					end
				else
					label = I18n.t("general.action.new").upcase_first
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "new"
					if options[:disable_button] != true
						link_tag_options[:class] += " btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "primary"}"
					end
					return @template.link_to(RugBuilder::IconBuilder.render(:new) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end

			# *********************************************************************
			# Edit
			# *********************************************************************
			
			def check_edit_link(options)
				return options[:paths] && options[:paths][:edit]
			end

			def get_edit_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = RugSupport::PathResolver.new(@template).resolve(path, object)
				if !options[:label].nil?
					if options[:label] != false
						label = options[:label]
					else
						label = ""
					end
				else
					label = I18n.t("general.action.edit").upcase_first
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "edit"
					if options[:disable_button] != true
						link_tag_options[:class] += " btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "primary"}"
					end
					return @template.link_to(RugBuilder::IconBuilder.render(:edit) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end
			
			# *********************************************************************
			# Create
			# *********************************************************************

			def check_create_link(options)
				return options[:paths] && options[:paths][:create]
			end

			def get_create_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = RugSupport::PathResolver.new(@template).resolve(path)
				if !options[:label].nil?
					if options[:label] != false
						label = options[:label]
					else
						label = ""
					end
				else
					label = I18n.t("general.action.bind").upcase_first
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "create"
					if options[:disable_button] != true
						link_tag_options[:class] += " btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "primary"}"
					end
					return @template.link_to(RugBuilder::IconBuilder.render(:new) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end

			# *********************************************************************
			# Destroy
			# *********************************************************************

			def check_destroy_link(options)
				return options[:paths] && options[:paths][:destroy]
			end

			def get_destroy_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = RugSupport::PathResolver.new(@template).resolve(path, object)
				if !options[:label].nil?
					if options[:label] != false
						label = options[:label]
					else
						label = ""
					end
				else
					label = I18n.t("general.action.destroy").upcase_first
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "destroy"
					if options[:disable_method_and_notification] != true
						link_tag_options[:method] = :delete
						link_tag_options[:data] = { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") }
					end
					if options[:disable_button] != true
						link_tag_options[:class] += " btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "danger"}"
					end
					return @template.link_to(RugBuilder::IconBuilder.render(:destroy) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end

			# *********************************************************************
			# Common actions
			# *********************************************************************

			def get_action_link(object, path, options = {})
				if !options[:show_if].nil? && options[:show_if].call(object) != true
					return ""
				end
				url = RugSupport::PathResolver.new(@template).resolve(path, object)
				if !options[:label].nil?
					if options[:label] != false
						label = options[:label]
					else
						label = ""
					end
				else
					label = ""
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"}"
					link_tag_options[:method] = options[:method] if options[:method]
					return @template.link_to(RugBuilder::IconBuilder.render(options[:icon]) + label, url, link_tag_options) + " "
				else
					return ""
				end
			end

			# *********************************************************************
			# Common actions
			# *********************************************************************

			def check_moving(options, function_options = {})
				result = true
				result = result && options[:moving] == true
				result = result && !options[:paths].blank?
				if function_options[:hierarchical] == true
					result = result && !options[:paths][:move_up].blank? && !options[:paths][:move_down].blank?
				else
					result = result && !options[:paths][:move].blank?
				end
				return result
			end

			def get_moving_link(options = {})
				link_tag_options = {}
				link_tag_options[:class] = "moving-handle btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"}"
				return @template.link_to(RugBuilder::IconBuilder.render(options[:icon] ? options[:icon] : :move) + options[:label].to_s, "#", link_tag_options) + " "
			end

			def get_moving_up_link(object, path, options = {})
				url = RugSupport::PathResolver.new(@template).resolve(path, object)
				link_tag_options = {}
				link_tag_options[:class] = "btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"}"
				link_tag_options[:method] = options[:method] ? options[:method] : "put"
				return @template.link_to(RugBuilder::IconBuilder.render(options[:icon] ? options[:icon] : :move_up) + options[:label].to_s, url, link_tag_options) + " "
			end

			def get_moving_down_link(object, path, options = {})
				url = RugSupport::PathResolver.new(@template).resolve(path, object)
				link_tag_options = {}
				link_tag_options[:class] = "btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"}"
				link_tag_options[:method] = options[:method] ? options[:method] : "put"
				return @template.link_to(RugBuilder::IconBuilder.render(options[:icon] ? options[:icon] : :move_down) + options[:label].to_s, url, link_tag_options) + " "
			end

		end
#	end
end