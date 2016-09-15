# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug button builder # TODO instance builder with template in initializer...
# *
# * Author: Matěj Outlý
# * Date  : 20. 7. 2016
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class ButtonBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
			end

			#
			# Render button 
			#
			def button(label, url = nil, options = {})
				style = options[:style] ? options[:style] : "default"
				size = options[:size] ? options[:size] : nil
				method = options[:method] ? options[:method] : nil
				color = options[:color] ? options[:color] : nil
				url = "#" if url.blank?

				# Check format
				if options[:format]
					format = options[:format]
				else
					format = :a
				end
				if ![:a, :button].include?(format)
					raise "Unknown format #{format}."
				end

				if !label.blank?
					if format == :a
						result = ""
						result += "<a 
							class=\"btn btn-#{style} #{size ? "btn-" + size : ""} #{color ? "color-" + color : ""}\" 
							#{method ? "data-method=\"" + method + "\"" : ""}
							href=\"#{url}\"
						>"
						result += label
						result += "</a>"
						return result.html_safe
					elsif format == :button
						result = ""
						result += "<button 
							type=\"button\"
							class=\"btn btn-#{style} #{size ? "btn-" + size : ""} #{color ? "color-" + color : ""}\" 
							#{method ? "data-method=\"" + method + "\"" : ""}
							#{url != "#" ? "onclick=\"window.location='" + url + "'\"" : ""}
						>" # TODO method not working here
						result += label
						result += "</button>"
						return result.html_safe
					end
				else
					return ""
				end
			end

			#
			# Render dropdown button with some options # TODO maybe some combination with menu builder...???
			#
			def dropdown_button(label = nil, options = {}, &block)
				style = options[:style] ? options[:style] : "default"
				size = options[:size] ? options[:size] : nil
				color = options[:color] ? options[:color] : nil
				label = RugBuilder::IconBuilder.render("caret-down") if label.blank?

				result = ""
				result += "<button 
					type=\"button\" 
					class=\"btn btn-#{style} #{size ? "btn-" + size : ""} #{color ? "color-" + color : ""} dropdown-toggle\" 
					data-toggle=\"dropdown\" 
					aria-haspopup=\"true\" 
					aria-expanded=\"false\"
				>"
				result += label
				result += "</button>"
				result += "<ul class=\"dropdown-menu\">"
				result += @template.capture(RugBuilder::MenuBuilder.new(@template), &block).to_s
				result += "</ul>"

				return result.html_safe
			end

			#
			# Render button group
			#
			def button_group(options = {}, &block)
				result = ""
				result += "<div class=\"btn-group\">"
				result += @template.capture(self, &block).to_s
				result += "</div>"
				return result.html_safe
			end

		end
#	end
end