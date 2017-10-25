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
				result = ""
				
				# Namespace
				namespace = self.options[:namespace]
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Label
				#label = options[:as] ? label_for(options[:as], label: options[:label]) : label_for(name, label: options[:label])
				#options[:label] = label

				# Value
				value = object.send(options[:as] ? options[:as] : name)
				value = value.split(",") if value.is_a?(::String)
				value = [value] if !value.blank? && !value.respond_to?(:each)

				# Attributes
				value_attr = (options[:value_attr] ? options[:value_attr] : :id)
				label_attr = (options[:label_attr] ? options[:label_attr] : :name)
					
				# Value as JSON
				if !value.blank?
					value_as_json = "[" 
					value_as_json += value.map do |item| 
						"{" +
						"#{value_attr.to_s}:'#{@template.escape_javascript((item.respond_to?(value_attr) ? item.send(value_attr) : item).to_s)}'," +
						"#{label_attr.to_s}:'#{@template.escape_javascript((item.respond_to?(label_attr) ? item.send(label_attr) : item).to_s)}'" +
						"}" 
					end.join(",")
					value_as_json += "]"
				end

				# Java Script
				result += @template.javascript_tag(%{
					function #{namespace ? namespace + "_" : ""}token_input_#{hash}_ready()
					{
						$('##{namespace ? namespace + "_" : ""}token_input_#{hash}').tokenInput('#{url}', {
							theme: 'facebook',
							hintText: '#{I18n.t("views.autocomplete.hint")}',
							noResultsText: '#{I18n.t("views.autocomplete.no_results")}',
							searchingText: '#{I18n.t("views.autocomplete.search_in_progress")}',
							placeholder: '#{options[:placeholder]}',
							minChars: #{options[:min_chars] ? options[:min_chars] : "3"},
							tokenLimit: #{options[:limit] ? options[:limit] : "null"},
							allowFreeTagging: #{options[:free_tagging] == true ? "true" : "false"},
							propertyToSearch: '#{label_attr ? label_attr : ""}',
							tokenValue: '#{value_attr ? value_attr : ""}',
							#{value_as_json ? "prePopulate: " + value_as_json + "," : ""}
						});
					}
					$(document).ready(#{namespace ? namespace + "_" : ""}token_input_#{hash}_ready);
				})
				
				# Options
				options[:id] = "token_input_#{hash}"

				# Field
				result += text_input_row(name, :text_field, options)

				return result.html_safe
			end

			def autocomplete_input_row(name, url, options = {})
				result = ""
				
				# Namespace
				namespace = self.options[:namespace]
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end
				
				# Java Script
				result += @template.javascript_tag(%{
					function #{namespace ? namespace + "_" : ""}autocomplete_input_#{hash}_ready()
					{
						$('##{namespace ? namespace + "_" : ""}autocomplete_input_#{hash}').autoComplete({
							minChars: 3,
							source: function(term, response){
								$.getJSON('#{url}', { q: term }, function(data) { response(data); });
							}
						});
					}
					$(document).ready(#{namespace ? namespace + "_" : ""}autocomplete_input_#{hash}_ready);
				})

				# Options
				options[:id] = "autocomplete_input_#{hash}"

				# Field
				result += text_input_row(name, :text_field, options)

				return result.html_safe

			end

		end
#	end
end