# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - phone
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def phone_row(name, options = {})
				result = ""

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# ID
				id = "phone-#{hash}"

				# Value
				value = object.send(name).to_s.gsub(" ", "")
				if !value.blank?
					if value.starts_with?("+")
						value = "+" + value[1..-1].scan(/.{3}/).join(" ")
					else
						value = value.scan(/.{3}/).join(" ")
					end
				end
				
				# Application JS code
				result += @template.javascript_tag(%{
					var rug_form_phone_#{hash} = null;
					$(document).ready(function() {
						rug_form_phone_#{hash} = new RugFormPhone('#{hash}');
						rug_form_phone_#{hash}.ready();
					});
				})

				# Inputs
				result_prefix = %{
					<div class="col-sm-4 m-b-sm">
						#{@template.select_tag("", @template.options_for_select(phone_prefixes), class: "form-control prefix")}
					</div>
				}
				result_suffix = %{
					<div class="col-sm-8 m-b-sm">
						#{@template.text_field_tag("", "", class: "form-control suffix")}
					</div>
				}
				
				result += %{
					<div id="#{id}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="backend" style="display: none;">
							#{@template.hidden_field_tag("#{object_name}[#{name.to_s}]", value)}
						</div>
						<div class="row frontend">
							#{result_prefix}
							#{result_suffix}
						</div>
						#{errors(name, errors: options[:errors]) }
					</div>
				}
				
				return result.html_safe
			end

		protected

			def phone_prefixes
				{
					"(+420) Česká republika" => "+420",
					"(+421) Slovensko" => "+421",
				}
			end

		end
#	end
end