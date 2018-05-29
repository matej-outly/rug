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
				
				# Common attributes
				options = options.nil? ? {} : options
				style = options[:style] ? options[:style] : "default"
				size = options[:size] ? options[:size] : nil
				color = options[:color] ? options[:color] : nil
				klass = options[:class] ? options[:class] : ""
				target = options[:target] ? options[:target] : nil
				active = (options[:active] == true)
				disabled = (options[:disabled] == true)
				id = options[:id] ? options[:id].to_s.to_id : nil
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
						
						# Attributes working for A format
						title = nil
						data = options[:data] ? options[:data] : nil
						method = options[:method] ? options[:method] : nil

						# Modal
						if !options[:modal].nil?
							data = {} if data.nil?
							data[:toggle] = "modal"
							data[:target] = "#" + options[:modal].to_s.to_id
						end

						# Tooltip
						if !options[:tooltip].nil?
							if !options[:modal].nil?

								# Tooltip defined but modal also defined -> we must create fake element inside A element with tooltip definition
								label = @template.content_tag(:span, label, class: "btn-inner", data: {
									toggle: "tooltip",
									placement: "top",
									container: "body"
								}, title: options[:tooltip])
								klass += " btn-with-inner"

							else 

								# Tooltip defined and modal not defined -> everything is ok, we can place data attribute
								data = {} if data.nil?
								data[:toggle] = "tooltip"
								data[:placement] = "top"
								data[:container] = "body"
								title = options[:tooltip]

							end
						end

						# Render
						return @template.link_to(label.html_safe, url, {
							class: "btn btn-#{style.to_s} #{size ? "btn-" + size.to_s : ""} #{color ? "color-" + color.to_s : ""} #{active ? "active" : ""} #{disabled ? "disabled" : ""} #{klass.to_s}",
							method: method,
							data: data,
							title: title,
							target: target,
							id: id
						})

					elsif format == :button

						# Render
						result = ""
						result += "<button 
							type=\"button\"
							class=\"btn btn-#{style.to_s} #{size ? "btn-" + size.to_s : ""} #{color ? "color-" + color.to_s : ""} #{active ? "active" : ""} #{klass.to_s}\" 
							#{id ? "id=\"" + id + "\"" : ""}
							#{disabled ? "disabled=\"disabled\"" : ""}
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
			# Render dropdown button with some options
			#
			def dropdown_button(label = nil, options = {}, &block)
				options = options.nil? ? {} : options
				style = options[:style] ? options[:style] : "default"
				size = options[:size] ? options[:size] : nil
				color = options[:color] ? options[:color] : nil
				horizontal = options[:horizontal] ? options[:horizontal].to_sym : :left
				vertical = options[:vertical] ? options[:vertical].to_sym : :down
				klass = options[:class] ? options[:class] : ""
				id = options[:id] ? options[:id].to_s.to_id : nil
				active = (options[:active] == true)
				label = RugBuilder::IconBuilder.new(@template).render("caret-down") if label.blank?

				result = ""
				result += "<div class=\"drop#{vertical.to_s}\">" if options[:wrap] != false
				result += "<button 
					type=\"button\" 
					class=\"btn btn-#{style.to_s} #{size ? "btn-" + size.to_s : ""} #{color ? "color-" + color.to_s : ""} #{active ? "active" : ""} dropdown-toggle #{klass.to_s}\" 
					data-toggle=\"dropdown\" 
					aria-haspopup=\"true\" 
					aria-expanded=\"false\"
					#{id ? "id=\"" + id + "\"" : ""}
				>"
				result += label
				result += "</button>"
				result += "<ul class=\"dropdown-menu #{horizontal == :right ? "dropdown-menu-right" : ""}\">" 
				result += @template.capture(RugBuilder::MenuBuilder.new(@template), &block).to_s
				result += "</ul>"
				result += "</div>" if options[:wrap] != false

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