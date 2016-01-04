# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

require "rug_builder/table_builder/columns"

# Parts
require "rug_builder/table_builder/show"
require "rug_builder/table_builder/index"
require "rug_builder/table_builder/editor"

module RugBuilder
	class TableBuilder
		
		#
		# Constructor
		#
		def initialize(template)
			@template = template
		end

	private

		def get_model_class(objects, options)
			
			# Model class
			if options[:model_class]
				model_class = options[:model_class].constantize
			else
				model_class = objects.class.to_s.deconstantize
				if !model_class.blank?
					model_class = model_class.constantize
				end
			end
			if model_class.blank?
				raise "Please supply model class to options or use ActiveRecord::Relation as collection."
			end

			return model_class
		end

		def normalize_columns(columns)
			columns = Columns.new(columns) if !columns.is_a? Columns
			columns.template = @template
			return columns
		end

		# *********************************************************************
		# Plugins
		# *********************************************************************

		def resolve_pagination(objects, options)
			if options[:pagination] == true
				return @template.paginate(objects)
			else
				return ""
			end
		end

		def resolve_summary(objects, model_class, options)
			if options[:summary] == true
				return "<div class=\"summary\">#{I18n.t("general.shown").upcase_first}: #{objects.length}#{(model_class.respond_to?(:count) ? ("/" + model_class.count.to_s) : "")}</div>"
			else
				return ""
			end
		end

		def resolve_sorting(column, options)
			result = ""
			if options[:sorting] 
				if options[:sorting] == true
					result = " <span class=\"sorting\">" + @template.link_to(I18n.t("general.action.sort"), sort: column.to_s, page: @template.params[:page]) + "</span>"
				elsif options[:sorting][column.to_sym]
					result = " <span class=\"sorting\">" + @template.link_to(I18n.t("general.action.sort"), sort: (options[:sorting][column.to_sym] == true ? column.to_s : options[:sorting][column.to_sym].to_s), page: @template.params[:page]) + "</span>"
				end
			end
			return result
		end

		# *********************************************************************
		# Links
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
				if link_options[:disable_method_and_notification] == true
					if link_options[:disable_button] == true
						return @template.link_to("<i class=\"icon-trash\"></i>".html_safe + label, url, class: "destroy")
					else
						return "<div class=\"medium danger btn icon-left entypo icon-trash\">#{@template.link_to(label, url, class: "destroy") }</div>"
					end
				else
					if link_options[:disable_button] == true
						return @template.link_to("<i class=\"icon-trash\"></i>".html_safe + label, url, method: :delete, class: "destroy", data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") } )
					else
						return "<div class=\"medium danger btn icon-left entypo icon-trash\">#{@template.link_to(label, url, method: :delete, class: "destroy", data: { confirm: I18n.t("general.are_you_sure", default: "Are you sure?") } ) }</div>"
					end
				end
			else
				return ""
			end
		end
		
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
				if link_options[:disable_button] == true
					return @template.link_to("<i class=\"icon-pencil\"></i>".html_safe + label, url, class: "edit")
				else
					return "<div class=\"medium primary btn icon-left entypo icon-pencil\">#{@template.link_to(label, url, class: "edit")}</div>"
				end
			else
				return ""
			end
		end

		def check_show_link(options)
			return options[:paths] && options[:paths][:show]
		end

		def get_show_link(object, label, options, link_options = {})
			url = RugSupport::PathResolver.new(@template).resolve(options[:paths][:show], object)
			if url
				label = I18n.t("general.action.show") if label.blank?
				if link_options[:disable_button] == true
					return @template.link_to(label, url)
				else
					return "<div class=\"medium default btn icon-left entypo icon-search full-width\">#{@template.link_to(label, url)}</div>"
				end
			else
				return label
			end
		end

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
				if link_options[:disable_button] == true
					return @template.link_to("<i class=\"icon-plus\"></i>".html_safe + label, url, class: "create")
				else
					return "<div class=\"medium primary btn icon-left entypo icon-plus\">#{@template.link_to(label, url, class: "create")}</div>"
				end
			else
				return ""
			end
		end

	end
end
