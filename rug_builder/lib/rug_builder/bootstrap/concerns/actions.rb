# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug builder
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
			
			def action(action, options = {}, &block)

				# Merge with builtin actions options if some defined
				options = builtin_actions_options[action.to_sym].merge(options) if builtin_actions_options[action.to_sym]
				
				# Save self to options
				options[:action] = action.to_sym

				# Optional block
				raise "Block must be defined if modal option enabled." if (options[:modal] == true || options[:modal].is_a?(String) || options[:modal].is_a?(Symbol)) && block.nil?
				options[:block] = block
				
				# Add to internal structures
				self.actions[action.to_sym] = options
				self.add_action(action, options) if self.respond_to?(:add_action, true) 

				# Either render in place or return empty string and hope that somebody calls render_action_link in the future
				if @render_action_in_place == true
					return render_action_link(action)
				else
					return ""
				end
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
				@actions = nil
				@actions_modals = nil
			end

			def actions
				@actions = {} if @actions.nil?
				return @actions
			end

			def actions_modals
				@actions_modals = [] if @actions_modals.nil?
				return @actions_modals
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

				# Disabled?
				if !options[:disabled].nil? && options[:disabled].call(object) == true
					disabled = true
				else
					disabled = false
				end

				if disabled
					url = "#"
				else
					if options[:modal] == true || options[:modal].is_a?(String) || options[:modal].is_a?(Symbol)

						# Unique modal ID
						if options[:modal].is_a?(String) || options[:modal].is_a?(Symbol)
							modal_id = options[:modal].to_s
						else
							if object
								modal_id = "#{self.id}-#{object.id}-#{options[:action]}-modal"
							else
								modal_id = "#{self.id}-#{options[:action]}-modal"
							end
						end

						# Empty URL
						url = "#"

						# Data for modal opening
						options[:data] = { 
							target: "##{modal_id.to_id}",
							toggle: "modal"
						}

						# Block
						block = options[:block]

						# Render modal
						self.actions_modals << self.modal_builder.render(modal_id) do |modal|
							if object
								@template.capture(modal, object, &block)
							else
								@template.capture(modal, &block)
							end
						end

					else
						
						# Resolve URL
						if object
							url = self.path_resolver.resolve(options[:path], object)
						else
							url = self.path_resolver.resolve(options[:path])
						end
						url = "#" if url.blank? && url != false
						
					end
				end

				# Common link tag options
				link_tag_options = {}
				link_tag_options[:class] = ""
				link_tag_options[:class] += "btn btn-#{options[:size] ? options[:size] : "xs"} btn-#{options[:style] ? options[:style] : "default"} " if options[:disable_button] != true
				link_tag_options[:class] += options[:class] if options[:class]
				link_tag_options[:method] = options[:method] if options[:method] && !disabled
				link_tag_options[:data] = options[:data] if options[:data]
				link_tag_options[:disabled] = "disabled" if disabled

				# Label
				label = ""
				label += self.icon_builder.render(options[:icon]) if options[:icon]
				if options[:label].nil? || options[:label] == ""
					if options[:default_label] != false
						label += options[:default_label].to_s
					end
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
				if url == false
					return label.html_safe
				else
					return @template.link_to(label.html_safe, url, link_tag_options)
				end
			end

			def render_actions_modals
				return self.actions_modals.join("\n")
			end

		end
	end
#end
end