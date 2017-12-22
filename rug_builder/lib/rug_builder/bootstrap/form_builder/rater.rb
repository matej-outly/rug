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
			# - item_width (integer)
			# - icon_base (string)
			# - icon_hover (string)
			# - icon_selected (string)
			# - symbol_base (string)
			# - symbol_hover (string)
			# - symbol_selected (string)
			# - hash (string)
			#
			def rater_row(name, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

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

				# Symbols
				if options[:symbol_base] && options[:symbol_hover] && options[:symbol_selected]
					symbol_base = options[:symbol_base]
					symbol_hover = options[:symbol_hover]
					symbol_selected = options[:symbol_selected]
				else
					symbol_base = @template.rug_icon((options[:icon_base] ? options[:icon_base] : "star-o"), class: "symbol-base").trim
					symbol_hover = @template.rug_icon((options[:icon_hover] ? options[:icon_hover] : "star"), class: "symbol-hover").trim
					symbol_selected = @template.rug_icon((options[:icon_selected] ? options[:icon_selected] : "star"), class: "symbol-selected").trim
				end

				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_rater_#{hash} = null;
					$(document).ready(function() {
						rug_form_rater_#{hash} = new RugFormRater('#{hash}', {
							#{ max ? "max: " + max.to_s + "," : "" }
							#{ step ? "step: " + step.to_s + "," : "" }
							#{ options[:item_width] ? "itemWidth: " + options[:item_width].to_s + "," : "" }
							symbolBase: '#{symbol_base}',
							symbolHover: '#{symbol_hover}',
							symbolSelected: '#{symbol_selected}',
						});
						rug_form_rater_#{hash}.ready();
					});
				})
				
				# Form group
				result += %{
					<div id="rater-#{hash}" class="rater form-group #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}]", value)}
						<div class="canvas"></div>
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

		end
#	end
end