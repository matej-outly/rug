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

				# Field options
				field_options = {}
				field_options[:class] = []
				field_options[:class] << options[:class] if !options[:class].nil?
				field_options[:class] << "editable"
				field_options[:class] << "editable-#{subtype.to_s}"
				field_options[:id] = "#{object_name}[#{name.to_s}]" # This is necessary for TinyMCE inline editor
				field_options[:name] = "#{object_name}[#{name.to_s}]"
				field_options[:data] = options[:data] if !options[:data].nil?

				# Value
				value = object.send(name)

				result = %{
					#{options[:form_group] != false ? "<div class=\"form-group " + (has_error?(name, errors: options[:errors]) ? "has-error" : "") + "\">" : ""}
						#{label_for(name, label: options[:label])}
						#{@template.content_tag(tag, value.to_s.html_safe, field_options)}
						#{errors(name, errors: options[:errors])}
					#{options[:form_group] != false ? "</div>" : ""}
				}

				return result.html_safe
			end

		end
#	end
end