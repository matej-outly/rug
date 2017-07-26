# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - crop
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def crop_row(name, options = {})
				result = ""

				if !self.options[:update_url] || (object.new_record? && !self.options[:create_url])
					raise "Please define update and create URL."
				end

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Value
				value = object.send(name)

				# Current crop
				crop_x = object.send("#{name.to_s}_crop_x".to_sym)
				crop_y = object.send("#{name.to_s}_crop_y".to_sym)
				crop_w = object.send("#{name.to_s}_crop_w".to_sym)
				crop_h = object.send("#{name.to_s}_crop_h".to_sym)
				already_cropped = object.send("#{name.to_s}_already_cropped?".to_sym)

				# Cropped and croppable styles
				cropped_style = object.send("#{name.to_s}_cropped_style".to_sym)
				croppable_style = object.send("#{name.to_s}_croppable_style".to_sym)

				# Cropped style geometry
				cropped_style_geometry = value.styles[cropped_style.to_sym].geometry
				splitted_cropped_style_geometry = cropped_style_geometry[0..-2].split("x")
				if splitted_cropped_style_geometry.length != 2
					raise "Unknown style geometry format '#{cropped_style_geometry}'"
				end
				cropped_style_width = splitted_cropped_style_geometry[0].to_i
				cropped_style_height = splitted_cropped_style_geometry[1].to_i
				if cropped_style_geometry[-1] == "#"
					cropped_style_aspect_ratio = (cropped_style_width.to_f / cropped_style_height.to_f).round(2)
				elsif cropped_style_geometry[-1] == ">"
					cropped_style_aspect_ratio = nil
				else
					raise "Unknown style geometry format '#{cropped_style_geometry}'"
				end

				result += @template.javascript_tag(%{
					var rug_form_crop_#{hash} = null;
					$(document).ready(function() {
						rug_form_crop_#{hash} = new RugFormCrop('#{hash}', {
							aspectRatio: #{cropped_style_aspect_ratio ? cropped_style_aspect_ratio : "null"},
							initial: #{already_cropped ? "{ x: " + crop_x.to_s + ", y: " + crop_y.to_s + ", width: " + crop_w.to_s + ", height: " + crop_h.to_s + "}" : "null"},
							croppableStyle: '#{croppable_style.to_s}',
						});
						rug_form_crop_#{hash}.ready();
					});
				})

				# Crop attributes
				crop_attributes = ""
				for attribute in [:crop_x, :crop_y, :crop_w, :crop_h]
					crop_attributes += hidden_field("#{name.to_s}_#{attribute.to_s}".to_sym, class: attribute)
				end

				# Container
				result += %{
					<div id="crop_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""}">
						#{label_for(name, label: options[:label])}
						#{crop_attributes}
						#{hidden_field("#{name.to_s}_perform_cropping".to_sym, value: "1")}
						<div class="cropbox">#{@template.image_tag(value.url("#{croppable_style.to_s}")) if value.exists?}</div>
					</div>
				}

				return result.html_safe
			end

		end
#	end
end