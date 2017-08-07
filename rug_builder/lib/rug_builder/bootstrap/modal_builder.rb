# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug modal builder
# *
# * Author: Matěj Outlý
# * Date  : 4. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class ModalBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
				@icon_builder = RugBuilder::IconBuilder
			end

			#
			# Main render method
			#
			def render(id, options = {}, &block)
				
				# ID
				@id = id.to_s.to_id

				# Options
				@options = options.nil? ? {} : options

				# Class
				klass = @options[:class] ? @options[:class] : ""

				# Render
				result = %{
					<div class="modal fade #{klass}" id="#{@id}" tabindex="-1" role="dialog" aria-labelledby="#{@id}-label">
						<div class="modal-dialog" role="document">
							<div class="modal-content">
								#{@template.capture(self, &block).to_s}
							</div>
						</div>
					</div>
				}
			
				return result.html_safe
			end

			#
			# Render modal header
			#
			def header(label, options = {})
				result = %{
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">#{@icon_builder.render(:close)}</span></button>
						<h4 class="modal-title" id="#{@id}-label">
							#{label}
						</h4>
					</div>
				}
				return result.html_safe
			end

			#
			# Render modal body
			#
			def body(options = {}, &block)
				result = %{
					<div class="modal-body">
						#{@template.capture(&block).to_s}
					</div>
				}
				return result.html_safe
			end

			#
			# Render modal footer
			#
			def footer(options = {}, &block)
				result = %{
					<div class="modal-footer">
						#{@template.capture(&block).to_s}
					</div>
				}
				return result.html_safe
			end

		protected

		end
#	end
end