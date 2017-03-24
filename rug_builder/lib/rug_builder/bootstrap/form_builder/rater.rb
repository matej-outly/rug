# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - rater
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Rater element to display rating stars
			#
			# Options:
			# - max (integer)
			# - step (:fullstar|:halfstar|float)
			# - icon_base (string)
			# - icon_hover (string)
			# - icon_selected (string)
			#
			def rater_row(name, options = {})
				result = ""
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Value
				value = object.send(name)
				
				# Max				
				if options[:max]
					max = options[:max].to_i
					if max <= 0 
						raise "Max value must be above zero."
					end
				else
					max = 5
				end

				# Step size
				if options[:step]
					if options[:step] == :fullstar
						step = 1.0
					elsif options[:step] == :halfstar
						step = 0.5
					else
						step = options[:step].to_f
					end
					if step <= 0.0 
						raise "Step value must be above zero."
					end
					if step > max.to_f 
						raise "Step value must be below max value (#{max})."
					end
				else
					step = 0.5
				end

				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_rater_#{hash} = null;
					$(document).ready(function() {
						rug_form_rater_#{hash} = new RugFormRater('#{hash}', {
							#{ max ? "max: " + max.to_s + "," : "" }
							#{ step ? "step: " + step.to_s + "," : "" }
							symbolBase: '#{@template.rug_icon((options[:icon_base] ? options[:icon_base] : "star-o"), class: "symbol-base").trim}',
							symbolHover: '#{@template.rug_icon((options[:icon_hover] ? options[:icon_hover] : "star"), class: "symbol-hover").trim}',
							symbolSelected: '#{@template.rug_icon((options[:icon_selected] ? options[:icon_selected] : "star"), class: "symbol-selected").trim}',
						});
						rug_form_rater_#{hash}.ready();
					});
				})
				
				# Form group
				result += %{
					<div id="rater_#{hash}" class="rater form-group #{(has_error?(name) ? "has-error" : "")}">
						#{label_for(name, options)}
						#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value)}
						<div class="canvas"></div>
						#{errors(name)}
					</div>
				}

				return result.html_safe
			end

		end
#	end
end