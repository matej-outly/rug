# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - editable
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def editable_row(name, options = {})
				
				# Tag
				if options[:tag]
					tag = options[:tag]
				else
					tag = :div
				end

				# Subtype
				if options[:subtype]
					subtype = options[:subtype]
				else
					subtype = :text
				end
				raise "Unknown sybtype #{subtype}." if ![:text, :string].include?(subtype)

				# CSS class
				klass = []
				klass << options[:class] if !options[:class].nil?
				klass << "editable"
				klass << "editable-#{subtype.to_s}"

				# ID
				id = "#{object_name}[#{name.to_s}]"

				# Value
				value = object.send(name)

				result = %{
					#{options[:form_group] != false ? "<div class=\"form-group " + (has_error?(name, errors: options[:errors]) ? "has-error" : "") + "\">" : ""}
						#{label_for(name, label: options[:label])}
						<#{tag} class="#{klass.join(" ")}" id="#{id}">
							#{value.to_s.html_safe}
						</#{tag}>
						#{errors(name, errors: options[:errors])}
					#{options[:form_group] != false ? "</div>" : ""}
				}

				return result.html_safe
			end

		end
#	end
end