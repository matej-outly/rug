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

			def get_show_link(object, label, options, link_options = {})
				url = RugSupport::PathResolver.new(@template).resolve(options[:paths][:show], object)
				if url
					label = I18n.t("general.action.show") if label.blank?
					return @template.link_to(label, url)
				else
					return label
				end
			end

			# *********************************************************************
			# Destroy
			# *********************************************************************

			def check_destroy_link(options)
				return options[:paths] && options[:paths][:destroy]
			end

			def get_destroy_link(object, options, link_options = {})
				url = RugSupport::PathResolver.new(@template).resolve(options[:paths][:destroy], object)
				if !link_options[:label].nil?
					if link_options[:label] != false
						label = link_options[:label]
					else
						label = ""
					end
				else
					label = I18n.t("general.action.destroy")
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "destroy"
					if link_options[:disable_method_and_notification] != true
						link_tag_options[:method] = :delete
						link_tag_options[:data] = { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") }
					end
					if link_options[:disable_button] != true
						link_tag_options[:class] += " btn btn-xs btn-danger"
					end
					return @template.link_to(self.format_icon("trash") + label, url, link_tag_options)
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

			def get_edit_link(object, options, link_options = {})
				url = RugSupport::PathResolver.new(@template).resolve(options[:paths][:edit], object)
				if !link_options[:label].nil?
					if link_options[:label] != false
						label = link_options[:label]
					else
						label = ""
					end
				else
					label = I18n.t("general.action.edit")
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "edit"
					if link_options[:disable_button] != true
						link_tag_options[:class] += " btn btn-xs btn-primary"
					end
					return @template.link_to(self.format_icon("pencil") + label, url, link_tag_options)
				else
					return ""
				end
			end

			# *********************************************************************
			# New
			# *********************************************************************
			
			def check_new_link(options)
				return options[:paths] && options[:paths][:new]
			end

			def get_new_link(options, link_options = {})
				url = RugSupport::PathResolver.new(@template).resolve(options[:paths][:new])
				if !link_options[:label].nil?
					if link_options[:label] != false
						label = link_options[:label]
					else
						label = ""
					end
				else
					label = I18n.t("general.action.new")
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "new"
					if link_options[:disable_button] != true
						link_tag_options[:class] += " btn btn-sm btn-primary"
					end
					return @template.link_to(self.format_icon("plus") + label, url, link_tag_options)
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

			def get_create_link(object, options, link_options = {})
				url = RugSupport::PathResolver.new(@template).resolve(options[:paths][:create])
				if !link_options[:label].nil?
					if link_options[:label] != false
						label = link_options[:label]
					else
						label = ""
					end
				else
					label = I18n.t("general.action.bind")
				end
				if url
					link_tag_options = {}
					link_tag_options[:class] = "create"
					if link_options[:disable_button] != true
						link_tag_options[:class] += " btn btn-xs btn-primary"
					end
					return @template.link_to(self.format_icon("plus") + label, url, link_tag_options)
				else
					return ""
				end
			end

			# *********************************************************************
			# Common actions
			# *********************************************************************

			def get_action_link(object, link_options = {})
				if link_options[:show_if].nil? || link_options[:show_if].call(object) == true
					url = RugSupport::PathResolver.new(@template).resolve(link_options[:path], object)
					if url
						link_tag_options = {}
						link_tag_options[:class] = "btn btn-xs btn-default"
						link_tag_options[:method] = link_options[:method] if link_options[:method]
						return @template.link_to(self.format_icon(link_options[:icon]) + link_options[:label], url, link_tag_options)
					else
						return ""
					end
				else
					return ""
				end
			end

		end
#	end
end