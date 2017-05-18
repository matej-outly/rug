# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug map builder
# *
# * Author: Matěj Outlý
# * Date  : 24. 11. 2015
# *
# *****************************************************************************

module RugBuilder
	class MapBuilder

		#
		# Constructor
		#
		def initialize(template)
			@template = template
		end

		#
		# Main render method
		#
		def render(name, options = {}, &block)
			
			# Unique hash
			@hash = Digest::SHA1.hexdigest(name.to_s)

			# Options
			@options = options

			# Wrapper
			result = ""
			result += "<div id=\"map_#{@hash}\" class=\"map\">"

			# Mapbox (canvas)
			result += "<div class=\"mapbox\"></div>"
			
			# Map application
			result += @template.javascript_tag(js_application(&block))

			# Wrapper
			result += "</div>"

			return result.html_safe
		end

		#
		# Render marker
		#
		def marker(name, latitude, longitude)
			return "rug_map_#{@hash}.addMarker('#{name.to_s}', #{latitude}, #{longitude});".html_safe
		end

		#
		# Render marker label
		#
		def marker_label(name, content)
			return "rug_map_#{@hash}.addMarkerLabel('#{name.to_s}', '#{content}');".html_safe
		end

		#
		# Render polygon
		#
		def polygon(name, points)
			return "rug_map_#{@hash}.addPolygon('#{name.to_s}', #{points.to_json});".html_safe
		end

		#
		# Render polygon label
		#
		def polygon_label(name, content)
			return "rug_map_#{@hash}.addPolygonLabel('#{name.to_s}', '#{content}');".html_safe
		end

	protected

		def js_application(&block)
			js = %{
				var rug_map_#{@hash} = null;
				$(document).ready(function() {
					rug_map_#{@hash} = new RugMap('#{@hash}', {
						#{ @options[:latitude] ? "latitude: #{@options[:latitude]}," : "" }
						#{ @options[:longitude] ? "longitude: #{@options[:longitude]}," : "" }
						#{ @options[:zoom] ? "zoom: #{@options[:zoom]}," : "" }
						#{ !@options[:scrollwheel].nil? ? "scrollwheel: #{@options[:scrollwheel] ? "true" : "false"}," : "" }
					});
					rug_map_#{@hash}.ready();
					#{ @template.capture(self, &block).to_s }
				});
			}
			return js
		end

	end
end