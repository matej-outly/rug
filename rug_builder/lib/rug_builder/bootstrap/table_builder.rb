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

# Parts
require "rug_builder/bootstrap/table_builder/links"
require "rug_builder/bootstrap/table_builder/show"
require "rug_builder/bootstrap/table_builder/index"
require "rug_builder/bootstrap/table_builder/editor"

module RugBuilder
#	module Bootstrap
		class TableBuilder
			
			#
			# Constructor
			#
			def initialize(template)
				@template = template
			end

		protected

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
			# Formatters
			# *********************************************************************

			def format_icon(icon)
				if !icon.blank?
					return "<span class=\"glyphicon glyphicon-#{icon}\" aria-hidden=\"true\"></span> ".html_safe
				else
					return ""
				end
			end

		end
#	end
end
