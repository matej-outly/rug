# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - section
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def conditional_section(section_name, condition_name, condition_rule, options = {}, &block)
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{section_name.to_s}")
				end

				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_conditional_section_#{hash} = null;
					$(document).ready(function() {
						rug_form_conditional_section_#{hash} = new RugFormConditionalSection('#{hash}', {
							conditionName: '#{object.class.model_name.param_key}[#{condition_name.to_s}]',
							conditionRule: "#{condition_rule.to_s}", // Quotation mark (") used instead of apostrophe ('). Apostrophe should be used inside condition rule to interpret string value
							formSelector: '##{self.options[:html][:id]}',
						});
						rug_form_conditional_section_#{hash}.ready();
					});
				})
				
				# Section
				result += @template.content_tag(:div, { :id => "conditional-section-#{hash}" }, &block)
				
				return result.html_safe
			end

			def conditional_label(label_name, condition_name, condition_rule, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{label_name.to_s}")
				end

				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_conditional_label_#{hash} = null;
					$(document).ready(function() {
						rug_form_conditional_label_#{hash} = new RugFormConditionalLabel('#{hash}', {
							conditionName: '#{object.class.model_name.param_key}[#{condition_name.to_s}]',
							conditionRule: "#{condition_rule.to_s}", // Quotation mark (") used instead of apostrophe ('). Apostrophe should be used inside condition rule to interpret string value
							conditionEffect: {
								#{options[:show] ? "show: '" + options[:show] + "'," : ""}
								#{options[:hide] ? "hide: '" + options[:hide] + "'," : ""}
							},
							formSelector: '##{self.options[:html][:id]}',
						});
						rug_form_conditional_label_#{hash}.ready();
					});
				})
				
				return result.html_safe
			end

		end
#	end
end