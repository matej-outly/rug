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
			#
			def list(objects, options = {}, &block)
				result = ""

				# Model class
				@model_class = get_model_class(objects, options)

				# Unique hash
				@hash = get_model_class_hash(@model_class)

				# Options
				@options = options

				# Block
				@block = block

				# Render
				result += "<div id=\"list-#{@hash}\" class=\"list row\">"
				objects.each do |object|
					result += render_item(object)
				end
				result += "</div>"

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
				return %{
					<div class="item col-md-12" data-id="#{object.id}">
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