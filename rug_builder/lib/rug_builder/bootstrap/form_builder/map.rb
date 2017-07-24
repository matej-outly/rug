# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - map
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def map_location_row(name, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end
				
				# Part labels
				label_latitude = (options[:label_latitude] ? options[:label_latitude] : I18n.t("general.attribute.geolocation.latitude"))
				label_longitude = (options[:label_longitude] ? options[:label_longitude] : I18n.t("general.attribute.geolocation.longitude"))
				
				# Part values
				value = object.send(name)
				value_latitude = value && value[:latitude] ? value[:latitude] : nil
				value_longitude = value && value[:longitude] ? value[:longitude] : nil
				
				# Field options
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_map_location_#{hash} = null;
					$(document).ready(function() {
						rug_form_map_location_#{hash} = new RugFormMapLocation('#{hash}', {
							latitude: #{options[:latitude] ? options[:latitude] : "null"},
							longitude: #{options[:longitude] ? options[:longitude] : "null"},
							zoom: #{options[:zoom] ? options[:zoom] : "null"}
						});
						rug_form_map_location_#{hash}.ready();
					});
				})
				
				# Form group
				result += %{
					<div id="map_location_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
						
							<div class="col-sm-6"><div class="input-group">
								<div class="input-group-addon">#{label_latitude.upcase_first}</div>
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][latitude]", value_latitude, class: klass.dup.concat(["latitude"]))}
								<div class="input-group-addon exchange" style="cursor: pointer;">#{@template.rug_icon("exchange")}</div>
							</div></div>

							<div class="col-sm-6"><div class="input-group">
								<div class="input-group-addon">#{label_longitude.upcase_first}</div>
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][longitude]", value_longitude, class: klass.dup.concat(["longitude"]))}
							</div></div>

							<div class="col-sm-12"><div class="mapbox"></div></div>
							#{errors(name, errors: options[:errors], class: "col-sm-12")}
						</div>
					</div>
				}
				
				return result.html_safe
			end

			def map_polygon_row(name, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Part values
				value = object.send(name)
				
				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_map_polygon_#{hash} = null;
					$(document).ready(function() {
						rug_form_map_polygon_#{hash} = new RugFormMapPolygon('#{hash}', {
							latitude: #{options[:latitude] ? options[:latitude] : "null"},
							longitude: #{options[:longitude] ? options[:longitude] : "null"},
							zoom: #{options[:zoom] ? options[:zoom] : "null"}
						});
						rug_form_map_polygon_#{hash}.ready();
					});
				})
				
				# Form group
				result += %{
					<div id="map_polygon_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
							#{@template.hidden_field_tag("#{object_name}[#{name.to_s}]", value.to_json)}
							<div class="col-sm-12"><div class="mapbox"></div></div>
							#{errors(name, errors: options[:errors], class: "col-sm-12")}
						</div>
					</div>
				}
				
				return result.html_safe
			end

			def address_location_row(name, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Part values
				value = object.send(name)
				value_latitude = value && value[:latitude] ? value[:latitude] : nil
				value_longitude = value && value[:longitude] ? value[:longitude] : nil
				value_level = value && value[:level] ? value[:level] : nil
				value_address = value && value[:address] ? value[:address] : nil
				
				# Address field options
				field_options = {}
				klass = []
				klass << "form-control address"
				klass << options[:class] if !options[:class].nil?
				field_options[:class] = klass.join(" ")
				
				# Java Script
				#js = ""
				
				# TODO sofar must be done in application JS

				#result += @template.javascript_tag(js)
				
				# Form group
				result += %{
					<div id="address_location_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}][level]", value_level, class: "level")}
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}][latitude]", value_latitude, class: "latitude")}
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}][longitude]", value_longitude, class: "longitude")}
						#{@template.text_field_tag("#{object_name}[#{name.to_s}][address]", value_address, field_options)}
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

		end
#	end
end