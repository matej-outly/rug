# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - button
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#
			# Render primary button or submit
			#
			def primary_button_row(method = :submit, options = {})

				# CSS class
				klass = []
				klass << "btn"
				klass << (!options[:style].nil? ? "btn-#{options[:style]}" : "btn-primary")
				klass << "btn-#{options[:size]}" if !options[:size].nil?
				klass << options[:class] if !options[:class].nil?
				
				# Field options
				field_options = {}
				field_options[:class] = klass.join(" ")
				field_options[:name] = options[:name] if options[:name]
				field_options[:value] = options[:value] if options[:value]
				field_options[:type] = options[:type] if options[:type]

				return self.method(method).call(options[:label], field_options)
			end

			#
			# Render common button
			#
			def button_row(label, url, options = {})
				
				# CSS class
				klass = []
				klass << "btn"
				klass << (!options[:style].nil? ? "btn-#{options[:style]}" : "btn-default")
				klass << "btn-#{options[:size]}" if !options[:size].nil?
				klass << options[:class] if !options[:class].nil?
				
				# Field options
				field_options = {}
				field_options[:class] = klass.join(" ")
				#field_options[:name] = options[:name] if options[:name]
				#field_options[:value] = options[:value] if options[:value]
				#field_options[:type] = options[:type] if options[:type]

				return @template.link_to(label, url, field_options)

			end

			#
			# Render link button
			#
			def link_button_row(label, url, options = {})
				options[:style] = "link"
				return self.button_row(label, url, options)
			end

			#
			# Render back link button
			#
			def back_link_button_row(options = {})
				label = options[:label] ? options[:label] : I18n.t("general.back").upcase_first
				return self.link_button_row(label, :back, options)
			end

		end
#	end
end