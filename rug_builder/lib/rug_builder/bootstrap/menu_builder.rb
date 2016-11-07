# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug menu builder
# *
# * Author: Matěj Outlý
# * Date  : 27. 4. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class MenuBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
				@path_resolver = RugSupport::PathResolver.new(@template)
				@button_builder = RugBuilder::ButtonBuilder.new(@template)
				@icon_builder = RugBuilder::IconBuilder
			end

			#
			# Main render method
			#
			def render(object, options = {}, &block)
				
				# Set context
				@object = object
				@options = options

				# Class
				klass = @options[:class] ? @options[:class] : ""

				# Format
				if @options[:format]
					@format = @options[:format]
				else
					@format = :ul
				end
				if ![:ul, :btn].include?(@format)
					raise "Unknown format #{@format}."
				end

				# Render
				if @format == :btn
					result = %{
						<div class="#{klass} btn-group">
							#{@template.capture(self, &block).to_s}
						</div>
					}
				else
					result = %{
						<ul class="#{klass}">
							#{@template.capture(self, &block).to_s}
						</ul>
					}
				end

				return result.html_safe
			end

			#
			# Render common item
			#
			def item(label, path, options = {})
				icon = options.delete(:icon)
				active = (options[:active] == true)
				klass = options[:class] ? options[:class] : ""
				label = @options[:labels] != false ? label : ""

				# Render
				if @format == :btn
					options[:style] = options[:style].nil? ? @options[:btn_style] : nil
					options[:size] = options[:size].nil? ? @options[:btn_size] : nil
					result = @button_builder.button((@icon_builder.render(icon) + label).html_safe, path, options)
				else
					result = %{
						<li class="#{active == true ? "active" : ""} #{klass}">
							#{@template.link_to((@icon_builder.render(icon) + label).html_safe, path, options)}
						</li>
					}
				end

				return result.html_safe
			end

			#
			# Render index item
			#
			def index_item(label = nil, path = nil, options = {})
				
				# Label
				label = I18n.t("headers.#{controller_path.gsub('/', '.')}.index", default: I18n.t("general.action.index")).upcase_first if label.nil?
				
				# Path
				if path.nil?
					if @options[:path_base].blank?
						raise "Please define path_base option or provide item path."
					end
					path = @path_resolver.resolve("#{@options[:path_base].pluralize}_path")
				else
					path = @path_resolver.resolve(path)
				end

				# Options
				options[:icon] = :index if options[:icon].nil?
				options[:active] = (@template.action_name == "index") if options[:active].nil?

				return self.item(label, path, options)
			end

			#
			# Render show item
			#
			def show_item(label = nil, path = nil, options = {})
				
				if @object.nil? || @object.new_record?
					return ""
				end

				# Label
				label = I18n.t("headers.#{controller_path.gsub('/', '.')}.show", default: I18n.t("general.action.show")).upcase_first if label.nil?
				
				# Path
				if path.nil?
					if @options[:path_base].blank?
						raise "Please define path_base option or provide item path."
					end
					path = @path_resolver.resolve("#{@options[:path_base].singularize}_path", @object)
				else
					path = @path_resolver.resolve(path, @object)
				end

				# Options
				options[:icon] = :show if options[:icon].nil?
				options[:active] = (@template.action_name == "show") if options[:active].nil?

				return self.item(label, path, options)
			end

			#
			# Render new item
			#
			def new_item(label = nil, path = nil, options = {})
				
				# Label
				label = I18n.t("headers.#{controller_path.gsub('/', '.')}.new", default: I18n.t("general.action.new")).upcase_first if label.nil?
				
				# Path
				if path.nil?
					if @options[:path_base].blank?
						raise "Please define path_base option or provide item path."
					end
					splitted_path_base = @options[:path_base].to_s.split(".")
					path = @path_resolver.resolve("#{(splitted_path_base.length > 1 ? splitted_path_base.slice(0..-2).join(".") + "." : "")}new_#{splitted_path_base.slice(-1).singularize}_path")
				else
					path = @path_resolver.resolve(path)
				end

				# Options
				options[:icon] = :new if options[:icon].nil?
				options[:active] = (@template.action_name == "new" || @template.action_name == "create") if options[:active].nil?
				options["data-no-turbolink"] = true

				return self.item(label, path, options)
			end

			#
			# Render edit item
			#
			def edit_item(label = nil, path = nil, options = {})
				
				if @object.nil? || @object.new_record?
					return ""
				end

				# Label
				label = I18n.t("headers.#{controller_path.gsub('/', '.')}.edit", default: I18n.t("general.action.edit")).upcase_first if label.nil?
				
				# Path
				if path.nil?
					if @options[:path_base].blank?
						raise "Please define path_base option or provide item path."
					end
					splitted_path_base = @options[:path_base].to_s.split(".")
					path = @path_resolver.resolve("#{(splitted_path_base.length > 1 ? splitted_path_base.slice(0..-2).join(".") + "." : "")}edit_#{splitted_path_base.slice(-1).singularize}_path", @object)
				else
					path = @path_resolver.resolve(path, @object)
				end

				# Options
				options[:icon] = :edit if options[:icon].nil?
				options[:active] = (@template.action_name == "edit" || @template.action_name == "update") if options[:active].nil?
				options["data-no-turbolink"] = true

				return self.item(label, path, options)
			end

			#
			# Render destroy item
			#
			def destroy_item(label = nil, path = nil, options = {})
				
				if @object.nil? || @object.new_record?
					return ""
				end

				# Label
				label = I18n.t("headers.#{controller_path.gsub('/', '.')}.destroy", default: I18n.t("general.action.destroy")).upcase_first if label.nil?
				
				# Path
				if path.nil?
					if @options[:path_base].blank?
						raise "Please define path_base option or provide item path."
					end
					path = @path_resolver.resolve("#{@options[:path_base].singularize}_path", @object)
				else
					path = @path_resolver.resolve(path, @object)
				end

				# Options
				options[:icon] = :destroy if options[:icon].nil?
				options[:method] = :delete
				options[:data] = { confirm: I18n.t('general.are_you_sure', default: "Are you sure?") }

				return self.item(label, path, options)
			end

			#
			# Render duplicate item
			#
			def duplicate_item(label = nil, path = nil, options = {})
				
				if @object.nil? || @object.new_record?
					return ""
				end

				# Label
				label = I18n.t("headers.#{controller_path.gsub('/', '.')}.duplicate", default: I18n.t("general.action.duplicate")).upcase_first if label.nil?
				
				# Path
				if path.nil?
					if @options[:path_base].blank?
						raise "Please define path_base option or provide item path."
					end
					path = @path_resolver.resolve("duplicate_#{@options[:path_base].singularize}_path", @object)
				else
					path = @path_resolver.resolve(path, @object)
				end

				# Options
				options[:icon] = :duplicate if options[:icon].nil?
				options[:method] = :post

				return self.item(label, path, options)
			end

		protected

			def controller_path
				return @template.controller.class.name.to_snake[0..-12]
			end

		end
#	end
end