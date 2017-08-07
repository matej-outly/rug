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
	module Concerns
		module Actions extend ActiveSupport::Concern

			# *************************************************************
			# Definitions
			# *************************************************************
			
			def action(action, options = {})

				# Merge with builtin actions options if some defined
				if builtin_actions_options[action.to_sym]
					options = builtin_actions_options[action.to_sym].merge(options)
				end

				# Add to internal structures
				self.actions[action.to_sym] = options
				self.add_action(action, options) if self.respond_to?(:add_action, true) 

				return ""
			end

		protected

			# *************************************************************
			# Builtin actions
			# *************************************************************

			def builtin_actions_options
				{
					new: {
						style: "primary",
						class: "link-new",
						icon: :new,
						default_label: I18n.t("general.action.new").upcase_first,
					},
					show: {
						class: "link-show",
						icon: :show,
						default_label: I18n.t("general.action.show").upcase_first,
					},
					edit: {
						style: "primary",
						class: "link-edit",
						icon: :edit,
						default_label: I18n.t("general.action.edit").upcase_first,
					},
					move: {
						icon: :move,
					},
					destroy: {
						style: "danger",
						class: "link-destroy",
						icon: :destroy,
						method: :delete,
						data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") },
						default_label: I18n.t("general.action.destroy").upcase_first,
					},
				}
			end

			# *************************************************************
			# Internal storage
			# *************************************************************

			def clear_actions
				@actions.nil?
			end

			def actions
				@actions = {} if @actions.nil?
				return @actions
			end

			# *************************************************************
			# Render
			# *************************************************************

			def render_action_link(action, options = {})
				raise "Unknown action '#{action.to_s}'." if !self.actions[action.to_sym]
				return self.render_link(self.actions[action.to_sym].merge(options))
			end

			def render_link(options = {})
				
				# Get object
				object = options[:object]

				# "Show if" condition
				if !options[:if].nil? 
					if object
						return options[:fallback] ? options[:fallback] : "" if options[:if].call(object) != true
					else
						return options[:fallback] ? options[:fallback] : "" if options[:if].call != true
					end
				end

				# URL
				if object
					url = @path_resolver.resolve(options[:path], object)
				else
					url = @path_resolver.resolve(options[:path])
				end
				url = "#" if url.blank?
				
				# Link tag options
				link_tag_options = {}
				link_tag_options[:class] = ""
				link_tag_options[:class] += "btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"} " if options[:disable_button] != true
				link_tag_options[:class] += options[:class] if options[:class]
				link_tag_options[:method] = options[:method] if options[:method]
				link_tag_options[:data] = options[:data] if options[:data]

				# Label
				label = ""
				label += @icon_builder.render(options[:icon]) if options[:icon]
				if options[:label].nil? || options[:label] == ""
					label += options[:default_label].to_s
				else
					if options[:label] != false
						if options[:label].is_a?(Proc)
							if object
								label += options[:label].call(object)
							else
								label += options[:label].call
							end
						else
							label += options[:label].to_s
						end
					end
				end
				
				# Render link
				return @template.link_to(label.html_safe, url, link_tag_options)
			end

		end
	end
#end
end