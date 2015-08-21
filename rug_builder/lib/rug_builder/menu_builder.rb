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
	class MenuBuilder

		#
		# Constructor
		#
		def initialize(template)
			@template = template
		end

		#
		# Main render method
		#
		def render(object, options = {}, &block)
			
			# Set context
			@object = object
			@options = options

			# Render
			return ("<ul class=\"#{!@options[:name].blank? ? @options[:name] : ""} menu\">" + @template.capture(self, &block).to_s + "</ul>").html_safe
		end

		#
		# Render common item
		#
		def item(label, path, options = {})
			result = ""

			icon = options.delete(:icon)
			active = options.delete(:active)

			result += "<li class=\"#{!icon.nil? ? ("icon-left icon-" + icon) : ""} #{active == true ? "active" : ""}\">"
			result += @template.link_to(label, path, options)
			result += "</li>"

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
					raise "Please define path_base option or provide item path"
				end
				path = RugSupport::PathResolver.new(@template).resolve("#{@options[:path_base].pluralize}_path")
			end

			# Options
			options[:icon] = "list" if options[:icon].nil?
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
					raise "Please define path_base option or provide item path"
				end
				path = RugSupport::PathResolver.new(@template).resolve("#{@options[:path_base].singularize}_path", @object)
			end

			# Options
			options[:icon] = "search" if options[:icon].nil?
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
					raise "Please define path_base option or provide item path"
				end
				splitted_path_base = @options[:path_base].to_s.split(".")
				path = RugSupport::PathResolver.new(@template).resolve("#{(splitted_path_base.length > 1 ? splitted_path_base.slice(0..-2).join(".") + "." : "")}new_#{splitted_path_base.slice(-1).singularize}_path")
			end

			# Options
			options[:icon] = "plus" if options[:icon].nil?
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
					raise "Please define path_base option or provide item path"
				end
				splitted_path_base = @options[:path_base].to_s.split(".")
				path = RugSupport::PathResolver.new(@template).resolve("#{(splitted_path_base.length > 1 ? splitted_path_base.slice(0..-2).join(".") + "." : "")}edit_#{splitted_path_base.slice(-1).singularize}_path", @object)
			end

			# Options
			options[:icon] = "pencil" if options[:icon].nil?
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
					raise "Please define path_base option or provide item path"
				end
				path = RugSupport::PathResolver.new(@template).resolve("#{@options[:path_base].singularize}_path", @object)
			end

			# Options
			options[:icon] = "trash" if options[:icon].nil?
			options[:method] = :delete
			options[:data] = { confirm: I18n.t('general.are_you_sure', default: "Are you sure?") }

			return self.item(label, path, options)
		end

	protected

		def controller_path
			return @template.controller.class.name.to_snake[0..-12]
		end

	end
end