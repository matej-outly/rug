# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - TextExt
# *
# * Author: Matěj Outlý
# * Date  : 29. 10. 2015
# *
# *****************************************************************************

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder

		def token_input_row(name, url, options = {})
			result = "<div class=\"element\">"
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# Label
			if !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Value
			value = object.send(options[:as] ? options[:as] : name)
			value = value.split(",") if value.is_a?(::String)
			value = [value] if !value.blank? && !value.is_a?(::Array)

			# Java Script
			js = ""

			js += "function token_input_#{hash}_ready()\n"
			js += "{\n"
			js += "	$('#token_input_#{hash}').tokenInput('#{url}', {\n"
			js += "		theme: 'facebook',\n"
			js += "		hintText: '#{I18n.t("views.autocomplete.hint")}',\n"
			js += "		noResultsText: '#{I18n.t("views.autocomplete.no_results")}',\n"
			js += "		searchingText: '#{I18n.t("views.autocomplete.search_in_progress")}',\n"
			js += "		minChars: 3,\n"
			if options[:limit]
				js += "		tokenLimit: #{options[:limit]},\n"
			end
			if options[:label_attr]
				js += "		propertyToSearch: '#{options[:label_attr]}',\n"
			end
			if options[:value_attr]
				js += "		tokenValue: '#{options[:value_attr]}',\n"
			end
			if !value.blank?
				value_attr = (options[:value_attr] ? options[:value_attr] : :id)
				label_attr = (options[:label_attr] ? options[:label_attr] : :name)
				value_as_json = "[" 
				value_as_json += value.map do |item| 
					"{" +
					"#{value_attr.to_s}:'#{@template.escape_javascript((item.respond_to?(value_attr) ? item.send(value_attr) : item).to_s)}'," +
					"#{label_attr.to_s}:'#{@template.escape_javascript((item.respond_to?(label_attr) ? item.send(label_attr) : item).to_s)}'" +
					"}" 
				end.join(",")
				value_as_json += "]"
				js += "		prePopulate: #{value_as_json},\n"
			end
			js += "	});\n"
			js += "}\n"
			js += "$(document).ready(token_input_#{hash}_ready);\n"

			# CSS
			css = ""
			css += "ul.token-input-list-facebook { width: auto; border: 1px solid #d8d8d8; -moz-border-radius: 4px; -webkit-border-radius: 4px; border-radius: 4px; }\n"
			css += "li.token-input-token-facebook { padding: 1px 6px; -moz-border-radius: 3px; -webkit-border-radius: 3px; border-radius: 3px; }\n"
			css += "li.token-input-input-token-facebook { margin: 3px 0 0 0; }\n"
			css += "div.token-input-dropdown-facebook { font-family: inherit; border: 1px solid #d8d8d8; -moz-border-radius: 4px; -webkit-border-radius: 4px; border-radius: 4px; box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2); }\n"
			css += "div.token-input-dropdown-facebook ul li.token-input-selected-dropdown-item-facebook { background-color: #33aaff; }\n"

			result += @template.javascript_tag(js)
			result += "<style>" + css + "</style>"
			
			# Field
			result += "<div class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			result += "<input type=\"text\" id=\"token_input_#{hash}\" name=\"#{object.class.model_name.param_key}[#{name.to_s}]\" />"
			result += "</div>"
			
			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

	end
end