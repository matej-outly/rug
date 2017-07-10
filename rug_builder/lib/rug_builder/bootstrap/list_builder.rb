# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug list builder
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2017
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class ListBuilder
			
			#
			# Constructor
			#
			def initialize(template)
				@template = template
				@path_resolver = RugSupport::PathResolver.new(@template)
				@icon_builder = RugBuilder::IconBuilder
			end

			#
			# Render list
			#
			# Options:
			# - item_template (hash|object)
			# - add_position (:append|:prepend)
			# - list_class
			# - item_class
			#
			def list(objects, options = {}, &block)
				result = ""

				# Model class
				@model_class = get_model_class(objects, options)

				# Unique hash
				@hash = get_model_class_hash(@model_class)

				# Options
				@options = options.nil? ? {} : options

				# Block
				@block = block

				# List CSS class
				list_class = !@options[:list_class].blank? ? @options[:list_class] : "row"

				# Render
				result += %{<div id="list-#{@hash}" class="list #{list_class}">}
				objects.each do |object|
					result += render_item(object)
				end
				result += %{</div>}

				# List JS application
				result += @template.javascript_tag(render_js)

				return result.html_safe
			end

		protected

			# *****************************************************************
			# Model class
			# *****************************************************************

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

			# *****************************************************************
			# Java Script
			# *****************************************************************

			def render_js
				js = %{
					var rug_list_#{@hash} = null;
					$(document).ready(function() {
						rug_list_#{@hash} = new RugList('#{@hash}', {
							
							// Common
							containerSelector: '',
							itemSelector: '> .item',
							itemTemplate: `
								#{render_item_template}
							`,

							// Adding
							addPosition: '#{@options[:add_position] ? @options[:add_position].to_s : "append" }',

							// Inline destroy
							inlineDestroy: #{@options[:inline_destroy] == true ? 'true' : 'false'},
							inlineDestroyConfirmTitle: '#{I18n.t("general.are_you_sure")}',
							inlineDestroyConfirmMessage: '#{I18n.t("general.are_you_sure_explanation")}',
							inlineDestroySuccessMessage: '#{I18n.t("general.action.messages.destroy.success")}',
							inlineDestroyErrorMessage: '#{I18n.t("general.action.messages.destroy.error")}',

						});
						rug_list_#{@hash}.ready();
					});
				}
				return js
			end

			# *****************************************************************
			# Item
			# *****************************************************************

			def render_item(object)
				
				# Item CSS class
				item_class = (!@options[:item_class].blank? ? @options[:item_class] : "col-md-12")
				item_class += " destroyable" if @options[:inline_destroy] == true
				
				# Data
				data_id = %{data-id="#{object.id}"}
				if @options[:inline_destroy] == true && @options[:inline_destroy_path]
					data_destroy = %{
						data-destroy-url="#{@path_resolver.resolve(@options[:inline_destroy_path], object)}\"
						data-destroy="a.link-destroy"
					}
				end

				return %{
					<div class="item #{item_class}" #{data_id} #{data_destroy}>
						#{@template.capture(object, &@block).to_s}
					</div>
				}
			end

			def render_item_template
				if @options[:item_template].blank?
					return ""
				end
				item_template = @options[:item_template]
				item_template = OpenStruct.new(item_template) if item_template.is_a?(Hash)
				return render_item(item_template)
			end

		end
#	end
end
