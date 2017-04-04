# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - crop TODO refactor JavaScript to object representation
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
				hash = Digest::SHA1.hexdigest(name.to_s)

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

				# Java Script
				# js = ""

				# js += "function crop_#{hash}_update_coords(coords) \n"
				# js += "{\n"
				# js += "	$('#crop_#{hash} .crop_x').val(coords.x);\n"
				# js += "	$('#crop_#{hash} .crop_y').val(coords.y);\n"
				# js += "	$('#crop_#{hash} .crop_w').val(coords.width);\n"
				# js += "	$('#crop_#{hash} .crop_h').val(coords.height);\n"
				# js += "}\n"

				# js += "function crop_#{hash}_reload_jcrop()\n"
				# js += "{\n"
				# js += "	var img = $('#crop_#{hash} .cropbox img');\n"
				# js += "	var jcrop_api = img.data('Jcrop');\n"
				# js += "	if (jcrop_api) {\n"
				# js += "		jcrop_api.destroy();\n"
				# js += "	}\n"
				# js += "	var natural_width = img.get(0).naturalWidth;\n"
				# js += "	var natural_height = img.get(0).naturalHeight;\n"
				# js += "	img.Jcrop({\n"
				# js += "		trueSize: [natural_width, natural_height],\n"
				# js += "		onChange: crop_#{hash}_update_coords,\n"
				# js += "		onSelect: crop_#{hash}_update_coords,\n"
				# if already_cropped # TODO Dynamic from hidden inputs
				# 	js += "		setSelect: [#{(crop_x <= crop_w ? crop_x : crop_x + crop_w)}, #{(crop_y <= crop_h ? crop_y : crop_y + crop_h)}, #{crop_w}, #{crop_h}],\n" # crop_x+crop_w / crop_y+crop_h: Hack overriding bug in jCrop
				# else
				# 	js += "		setSelect: [0, 0, #{cropped_style_width}, #{cropped_style_height}],\n"
				# end
				# if cropped_style_aspect_ratio
				# 	js += "		aspectRatio: #{cropped_style_aspect_ratio},\n"
				# end
				# js += "	});\n"
				# js += "}\n"

				# js += "function crop_#{hash}_reload(id)\n"
				# js += "{\n"
				# js += "	$.ajax({\n"
				# js += "		dataType: 'json',\n"
				# js += "		url: '#{RugSupport::PathResolver.new(@template).resolve(self.options[:update_url], ":id")}'.replace(':id', id),\n" # Update URL is similar to show URL
				# js += "		success: function(callback) {\n"
				# js += "			if (callback && callback.#{name.to_s}_url) {\n"
				# js += "				var src = callback.#{name.to_s}_url.replace('/original/', '/#{croppable_style.to_s}/');\n"
				# js += "				$('#crop_#{hash} .cropbox').html('<img src=\\'' + src + '\\' />');\n"
				# js += "				$('#crop_#{hash} .cropbox img').load(crop_#{hash}_reload_jcrop);\n"
				# js += "			}\n"
				# js += "		}\n"
				# js += "	});\n"
				# js += "}\n"

				# js += "function crop_#{hash}_ready()\n"
				# js += "{\n"
				# js += "	$('#crop_#{hash} .cropbox img').load(crop_#{hash}_reload_jcrop);\n"
				# js += "	if ($('#crop_#{hash} .cropbox img').length > 0) crop_#{hash}_reload_jcrop();\n"
				# js += "}\n"

				# js += "$(document).ready(crop_#{hash}_ready);\n"

				result += @template.javascript_tag(%{
					var rug_crop_#{hash} = null;
					$(document).ready(function() {
						rug_crop_#{hash} = new RugCrop('#{hash}', {
							aspectRatio: #{cropped_style_aspect_ratio ? cropped_style_aspect_ratio : "null"},
							initial: {
								x: #{already_cropped ? crop_x : 0},
								y: #{already_cropped ? crop_y : 0},
								width: #{already_cropped ? crop_w : cropped_style_width},
								height: #{already_cropped ? crop_h : cropped_style_height},
							}
						});
						rug_crop_#{hash}.ready();
					});
				})

				# Container
				result += "<div id=\"crop_#{hash}\" class=\"form-group\">"

				# Label
				result += label_for(name, options)

				# Crop attributes
				for attribute in [:crop_x, :crop_y, :crop_w, :crop_h]
					result += hidden_field("#{name.to_s}_#{attribute.to_s}".to_sym, class: attribute)
				end
				result += hidden_field("#{name.to_s}_perform_cropping".to_sym, value: "1")

				# Cropbox (image)
				result += "<div class=\"cropbox\">"
				result += @template.image_tag(value.url("#{croppable_style.to_s}")) if value.exists?
				result += "</div>"

				# Container end
				result += "</div>"

				return result.html_safe
			end

		end
#	end
end