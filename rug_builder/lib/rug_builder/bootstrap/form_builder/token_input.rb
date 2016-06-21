# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - token input
# *
# * Author: Matěj Outlý
# * Date  : 29. 10. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def token_input_row(name, url, options = {})
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Value
				value = object.send(options[:as] ? options[:as] : name)
				value = value.split(",") if value.is_a?(::String)
				value = [value] if !value.blank? && !value.respond_to?(:each)

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
				
				# Options
				options[:id] = "token_input_#{hash}"

				# Field
				result = ""
				result += @template.javascript_tag(js)
				result += text_input_row(name, :text_field, options)

				return result.html_safe
			end

			def autocomplete_input_row(name, url, options = {})
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)
				
				# Java Script
				js = ""

				js += "function autocomplete_input_#{hash}_ready()\n"
				js += "{\n"
				js += "	$('#autocomplete_input_#{hash}').autoComplete({\n"
				js += "		minChars: 3,\n"
				js += "		source: function(term, response){\n"
				js += "			$.getJSON('#{url}', { q: term }, function(data){ response(data); });\n"
				js += "		}\n"
				js += "	});\n"
				js += "}\n"
				js += "$(document).ready(autocomplete_input_#{hash}_ready);\n"

				# Options
				options[:id] = "autocomplete_input_#{hash}"

				# Field
				result = ""
				result += @template.javascript_tag(js)
				result += text_input_row(name, :text_field, options)

				return result.html_safe

			end

		end
#	end
end