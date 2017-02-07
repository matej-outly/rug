# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder - common util functions
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
			# Model class
			# *********************************************************************

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

			def get_model_class_hash(model_class)
				return Digest::SHA1.hexdigest(model_class.to_s)
			end

			# *********************************************************************
			# Columns
			# *********************************************************************

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
			# Actions / global actions
			# *********************************************************************

			def prepare_actions(options, options_attr, builtin_actions, default_link_options)
				result = {}
				if options[options_attr]
					options[options_attr].each do |action, link_options|
						found = false

						# Default link actions
						default_link_options.each do |key, default_value|
							link_options[key] = default_value if link_options[key].nil?
						end
						
						# Check builtin actions
						builtin_actions.each do |builtin_action|
							if action == builtin_action
								found = true
								result[action] = {
									block: lambda { |object| self.method("get_#{builtin_action}_link").call(object, link_options[:path], link_options) }
								}
							end
						end

						# Not-builtin action
						if !found
							result[action] = {
								block: lambda { |object| get_action_link(object, link_options[:path], link_options) }
							}
						end
					end
				end

				# Add all builtin actions if not defined by common actions
				builtin_actions.each do |builtin_action|
					if (options[options_attr].nil? || options[options_attr][builtin_action].nil?) && self.send("check_#{builtin_action}", options)
						result[builtin_action] = {
							block: lambda { |object| self.method("get_#{builtin_action}_link").call(object, options[:paths][builtin_action], default_link_options) }
						}
					end
				end
				
				return result
			end

			# *********************************************************************
			# Checkers
			# *********************************************************************

			def check_show(options)
				return options[:paths] && options[:paths][:show]
			end

			def check_new(options)
				return options[:paths] && options[:paths][:new]
			end

			def check_edit(options)
				return options[:paths] && options[:paths][:edit]
			end

			def check_create(options)
				return options[:paths] && options[:paths][:create]
			end

			def check_inline_destroy(options)
				return options[:paths] && options[:paths][:destroy] && options[:inline_destroy] == true
			end

			def check_destroy(options)
				return options[:paths] && options[:paths][:destroy]
			end

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

		end
	#end
end