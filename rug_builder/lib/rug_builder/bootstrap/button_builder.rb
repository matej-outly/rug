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
				options = options.nil? ? {} : options
				style = options[:style] ? options[:style] : "default"
				size = options[:size] ? options[:size] : nil
				color = options[:color] ? options[:color] : nil
				klass = options[:class] ? options[:class] : ""
				method = options[:method] ? options[:method] : nil
				active = (options[:active] == true)
				data = options[:data] ? options[:data] : nil
				url = "#" if url.blank?
				title = nil

				# Tooltip
				if !options[:tooltip].nil?
					data = {} if data.nil?
					data[:toggle] = "tooltip"
					data[:placement] = "top"
					data[:container] = "body"
					title = options[:tooltip]
				end

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
						return @template.link_to(label.html_safe, url, {
							class: "btn btn-#{style} #{size ? "btn-" + size : ""} #{color ? "color-" + color : ""} #{active ? "active" : ""} #{klass}",
							method: method,
							data: data,
							title: title
						}) 
					elsif format == :button
						result = ""
						result += "<button 
							type=\"button\"
							class=\"btn btn-#{style} #{size ? "btn-" + size : ""} #{color ? "color-" + color : ""} #{active ? "active" : ""} #{klass}\" 
							#{url != "#" ? "onclick=\"window.location='" + url + "'\"" : ""}
						>" # method and data not working here, hence tooltip not working here
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
				options = options.nil? ? {} : options
				style = options[:style] ? options[:style] : "default"
				size = options[:size] ? options[:size] : nil
				color = options[:color] ? options[:color] : nil
				klass = options[:class] ? options[:class] : ""
				active = (options[:active] == true)
				label = RugBuilder::IconBuilder.render("caret-down") if label.blank?

				result = ""
				result += "<button 
					type=\"button\" 
					class=\"btn btn-#{style} #{size ? "btn-" + size : ""} #{color ? "color-" + color : ""} #{active ? "active" : ""} dropdown-toggle #{klass}\" 
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
				options = options.nil? ? {} : options
				klass = options[:class] ? options[:class] : ""

				result = ""
				result += "<div class=\"btn-group #{klass}\">"
				result += @template.capture(self, &block).to_s
				result += "</div>"
				return result.html_safe
			end

		end
#	end
end