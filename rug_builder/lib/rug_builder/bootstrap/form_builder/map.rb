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
				result = "<div class=\"form-horizontal\">"
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Label
				result += compose_label(name, options)

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
	
				# Library JS
				result += @template.javascript_tag(%{
					function RugFormMapLocation(hash, options)
					{
						this.DEFAULT_LATITUDE = 50.0596696; /* Prague */
						this.DEFAULT_LONGITUDE = 14.4656239;
						this.DEFAULT_ZOOM = 9;
						this.map = null;
						this.marker = null;
						this.hash = hash;
						this.options = (typeof options !== 'undefined' ? options : {});
					}
					RugFormMapLocation.prototype = {
						constructor: RugFormMapLocation,
						updateInputs: function()
						{
							if (this.marker != null) {
								$('#map_location_' + this.hash + ' input.latitude').val(this.marker.getPosition().lat());
								$('#map_location_' + this.hash + ' input.longitude').val(this.marker.getPosition().lng());
							} else {
								$('#map_location_' + this.hash + ' input.latitude').val(null);
								$('#map_location_' + this.hash + ' input.longitude').val(null);
							}
							return true;
						},
						updateMap: function()
						{
							var latitude = parseFloat($('#map_location_' + this.hash + ' input.latitude').val());
							var longitude = parseFloat($('#map_location_' + this.hash + ' input.longitude').val());
							if (latitude && longitude) {
								this.setMarker(latitude, longitude);
							} else {
								this.removeMarker();
							}
							return true;
						},
						setMarker: function(latitude, longitude)
						{
							var _this = this;
							if (this.marker == null) {
								this.marker = new google.maps.Marker({
									map: this.map,
									draggable: true,
									position: {lat: latitude, lng: longitude}
								});
								this.marker.addListener('dragend', function(event) {
									_this.updateInputs();
								});
								this.marker.addListener('click', function() {
									_this.removeMarker();
									_this.updateInputs();
								});
							} else {
								this.marker.setPosition({lat: latitude, lng: longitude});
							}
							this.map.panTo({lat: latitude, lng: longitude});
							return true;
						},
						removeMarker: function()
						{
							if (this.marker != null) {
								this.marker.setMap(null);
								this.marker = null;
							}
							return true;
						},
						ready: function()
						{
							var _this = this;
							var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);
							var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);
							var zoom = (this.options.zoom ? this.options.zoom : this.DEFAULT_ZOOM);
							var mapCanvas = $('#map_location_' + this.hash + ' .mapbox').get(0);
							var mapPosition = new google.maps.LatLng(latitude, longitude);
							var mapOptions = {
								center: mapPosition,
								zoom: zoom,
								mapTypeId: google.maps.MapTypeId.ROADMAP,
							}
							this.map = new google.maps.Map(mapCanvas, mapOptions);
							google.maps.event.addListener(this.map, 'click', function(event) {
								_this.setMarker(event.latLng.lat(), event.latLng.lng());
								_this.updateInputs();
							});
							$('#map_location_' + this.hash + ' input.latitude').on('change', function() { _this.updateMap(); });
							$('#map_location_' + this.hash + ' input.longitude').on('change', function() { _this.updateMap(); });
							this.updateMap();
						},
						repair: function()
						{
							google.maps.event.trigger(this.map, 'resize');
							this.updateMap();
						}
					}
				})
				result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
				
				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_map_location_#{hash} = null;
					$(document).ready(function() {
						rug_form_map_location_#{hash} = new RugFormMapLocation('#{hash}', {
							latitude: #{@options[:latitude] ? @options[:latitude] : "null"},
							longitude: #{@options[:longitude] ? @options[:longitude] : "null"},
							zoom: #{@options[:zoom] ? @options[:zoom] : "null"}
						});
						rug_form_map_location_#{hash}.ready();
					});
				})
				
				# Form group
				result += "<div id=\"map_location_#{hash}\" class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"
				
				# Text inputs
				result += "<div class=\"col-sm-6\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_latitude.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][latitude]", value_latitude, class: klass.dup.concat(["latitude"]))
				result += "</div></div>"

				result += "<div class=\"col-sm-6\"><div class=\"input-group\">"
				result += "<div class=\"input-group-addon\">#{label_longitude.upcase_first}</div>"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][longitude]", value_longitude, class: klass.dup.concat(["longitude"]))
				result += "</div></div>"

				# Mapbox (canvas)
				result += "<div class=\"col-sm-12\">"
				result += "<div class=\"mapbox\"></div>"
				result += "</div>"

				# Errors
				result += errors(name, class: "col-sm-12")
				
				# Form group
				result += "</div>"

				result += "</div>"
				return result.html_safe
			end

			def map_polygon_row(name, options = {})
				result = "<div class=\"form-horizontal\">"
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Label
				result += compose_label(name, options)

				# Part values
				value = object.send(name)
				
				# Library JS
				result += @template.javascript_tag(%{
					function RugFormMapPolygon(hash, options)
					{
						this.DEFAULT_LATITUDE = 50.0596696; /* Prague */
						this.DEFAULT_LONGITUDE = 14.4656239;
						this.DEFAULT_ZOOM = 9;
						this.map = null;
						this.markers = [];
						this.polygon = null;
						this.hash = hash;
						this.options = (typeof options !== 'undefined' ? options : {});
					}
					RugFormMapPolygon.prototype = {
						constructor: RugFormMapPolygon,
						updateInput: function()
						{
							var value = null;
							if (this.markers.length > 0) {
								value = [];
								for (var i = 0; i < this.markers.length; i++) {
									var marker = this.markers[i];
									value.push([marker.getPosition().lat(),marker.getPosition().lng()]);
								}
								value = JSON.stringify(value);
							} else {
								value = '';
							}
							$('#map_polygon_' + this.hash + ' input').val(value);
							return true;
						},
						updateMap: function()
						{
							var value = $('#map_polygon_' + this.hash + ' input').val();
							value = JSON.parse(value);
							this.clearMarkers();
							if (value instanceof Array) {
								for (var i = 0; i < value.length; i++) {
									if (value[i] instanceof Array && value[i].length == 2) {
										this.addMarker(parseFloat(value[i][0]), parseFloat(value[i][1]));
									} else {
										this.clearMarkers();
										return false;
									}
								}
							}
							this.redrawPolygon();
							return true;
						},
						addMarker: function(latitude, longitude)
						{
							var _this = this;
							var marker = new google.maps.Marker({
								map: this.map,
								draggable: true,
								position: {lat: latitude, lng: longitude}
							});
							marker.addListener('dragend', function(event) {
								_this.redrawPolygon();
								_this.updateInput();
							});
							marker.addListener('click', function() {
								_this.removeMarker(marker);
								_this.redrawPolygon();
								_this.updateInput();
							});
							this.markers.push(marker);
							this.map.panTo({lat: latitude, lng: longitude});
						},
						removeMarker: function(marker)
						{
							marker.setMap(null);
							for (var i = 0; i < this.markers.length; i++) {
								if (marker == this.markers[i]) {
									this.markers.splice(i, 1);
									break;
								}
							}
						},
						clearMarkers: function()
						{
							for (var i = 0; i < this.markers.length; i++) {
								var marker = this.markers[i];
								marker.setMap(null);
							}
							this.markers = [];
						},
						redrawPolygon: function() 
						{
							if (this.polygon != null) {
								this.polygon.setMap(null);
								this.polygon = null;
							}
							var points = [];
							for (var i = 0; i < this.markers.length; i++) {
								var marker = this.markers[i];
								points.push({lat: marker.getPosition().lat(), lng: marker.getPosition().lng()});
							}
							this.polygon = new google.maps.Polygon({
								paths: points,
								strokeColor: '#FF0000',
								strokeOpacity: 0.8,
								strokeWeight: 2,
								fillColor: '#FF0000',
								fillOpacity: 0.2
							});
							this.polygon.setMap(this.map);
						},
						ready: function()
						{
							var _this = this;
							var latitude = (this.options.latitude ? this.options.latitude : this.DEFAULT_LATITUDE);
							var longitude = (this.options.longitude ? this.options.longitude : this.DEFAULT_LONGITUDE);
							var zoom = (this.options.zoom ? this.options.zoom : this.DEFAULT_ZOOM);
							var mapCanvas = $('#map_polygon_' + this.hash + ' .mapbox').get(0);
							var mapPosition = new google.maps.LatLng(latitude, longitude);
							var mapOptions = {
								center: mapPosition,
								zoom: zoom,
								mapTypeId: google.maps.MapTypeId.ROADMAP,
							}
							this.map = new google.maps.Map(mapCanvas, mapOptions);
							google.maps.event.addListener(this.map, 'click', function(event) {
								_this.addMarker(event.latLng.lat(), event.latLng.lng());
								_this.redrawPolygon();
								_this.updateInput();
							});
							this.updateMap();
						},
						repair: function()
						{
							google.maps.event.trigger(this.map, 'resize');
							this.updateMap();
						}
					}
				})
				result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"

				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_map_polygon_#{hash} = null;
					$(document).ready(function() {
						rug_form_map_polygon_#{hash} = new RugFormMapPolygon('#{hash}', {
							latitude: #{@options[:latitude] ? @options[:latitude] : "null"},
							longitude: #{@options[:longitude] ? @options[:longitude] : "null"},
							zoom: #{@options[:zoom] ? @options[:zoom] : "null"}
						});
						rug_form_map_polygon_#{hash}.ready();
					});
				})
				
				# Form group
				result += "<div id=\"map_polygon_#{hash}\" class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"
				
				# Input
				result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value.to_json)

				# Mapbox (canvas)
				result += "<div class=\"col-sm-12\">"
				result += "<div class=\"mapbox\"></div>"
				result += "</div>"

				# Errors
				result += errors(name, class: "col-sm-12")
				
				# Form group
				result += "</div>"

				result += "</div>"
				return result.html_safe
			end

			def address_location_row(name, options = {})
				result = "<div class=\"form-horizontal\">"
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Label
				result += compose_label(name, options)

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

				#result += "<script src=\"https://maps.googleapis.com/maps/api/js\"></script>"
				#result += @template.javascript_tag(js)
				
				# Form group
				result += "<div id=\"address_location_#{hash}\" class=\"form-group #{(has_error?(name) ? "has-error" : "")}\">"
				
				# Level input
				result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][level]", value_level, class: "level")
				
				# Location inputs
				result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][latitude]", value_latitude, class: "latitude")
				result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][longitude]", value_longitude, class: "longitude")
				
				# Address input
				result += "<div class=\"col-sm-12\">"
				result += @template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][address]", value_address, field_options)
				result += "</div>"
				
				# Errors
				result += errors(name, class: "col-sm-12")
				
				# Form group
				result += "</div>"

				result += "</div>"
				return result.html_safe
			end

		end
#	end
end