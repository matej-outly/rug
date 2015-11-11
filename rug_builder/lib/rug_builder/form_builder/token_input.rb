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
			value = object.send(name)
			if value.is_a? String
				value = value.split(",")
			end

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
			if options[:label_attr]
				js += "		propertyToSearch: '#{options[:label_attr]}',\n"
			end
			if options[:value_attr]
				js += "		tokenValue: '#{options[:value_attr]}',\n"
			end
			if !value.blank?
				value_as_json = "[" + (value.map { |part| "{name:'#{@template.escape_javascript(part)}'}" }.join(",")) + "]"
				js += "		prePopulate: #{value_as_json},\n"
			end
			js += "	});\n"
			js += "}\n"
			js += "$(document).ready(token_input_#{hash}_ready);\n"

			result += @template.javascript_tag(js)
			
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