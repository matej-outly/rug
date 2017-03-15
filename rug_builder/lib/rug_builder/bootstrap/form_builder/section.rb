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

			def conditional_section(section_name, condition_name, condition_rule, &block)
				result = ""
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(section_name.to_s)

				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_conditional_section_#{hash} = null;
					$(document).ready(function() {
						rug_form_conditional_section_#{hash} = new RugFormConditionalSection('#{hash}', {
							conditionName: '#{object.class.model_name.param_key}[#{condition_name.to_s}]',
							conditionRule: "#{condition_rule.to_s}" // " used before ' should be used inside condition rule to interpret string value
						});
						rug_form_conditional_section_#{hash}.ready();
					});
				})
				
				# Section
				result += @template.content_tag(:div, { :id => "conditional-section-#{hash}" }, &block)
				
				return result.html_safe
			end

		end
#	end
end