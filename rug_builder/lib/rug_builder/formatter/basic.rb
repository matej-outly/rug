# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - basic types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# String
		# *********************************************************************

		def self.string(value, options = {})
			return "" if value.blank?

			# No break?
			value = value.to_s.gsub(" ", "&nbsp;").html_safe if options[:no_break] == true
				
			# Truncate?
			value = value.to_s.truncate(options[:truncate].is_a?(Hash) ? options[:truncate] : {}) if !options[:truncate].nil? && options[:truncate] != false
			
			return value.to_s
		end

		# *********************************************************************
		# Text
		# *********************************************************************

		def self.text(value, options = {})
			return "" if value.blank?

			# Check format
			if options[:format]
				format = options[:format]
			else
				format = :raw
			end
			if ![:raw, :text_box].include?(format)
				raise "Unknown format #{format}."
			end

			if options[:more] == true

				# Object
				if options[:object].nil?
					raise "Please, supply object in options."
				end
				object = options[:object]

				# Column
				if options[:column].nil?
					raise "Please, supply column in options."
				end
				column = options[:column]

			end

			# Value
			modified_value = value

			# Strip tags
			modified_value = modified_value.to_s.strip_tags if options[:strip_tags] == true

			# Truncate
			modified_value = modified_value.to_s.truncate(options[:truncate].is_a?(Hash) ? options[:truncate] : {}) if options[:truncate] != false
			
			# More
			if options[:more] == true
				more_modal_id = "#{object.class.to_s}_#{object.id.to_s}_#{column.to_s}_modal"
				more_modal = RugBuilder::ModalBuilder.new(@template).render(more_modal_id) do |m|
					result = m.header(object.class.human_attribute_name(column))
					result += m.body { |b| value }
					result
				end
				modified_value += RugBuilder::ButtonBuilder.new(@template).button(I18n.t("general.more"), nil, modal: more_modal_id, style: :raw)
			end

			# Format
			if format == :text_box
				result = %{
					<div class="text-box">
						#{modified_value}
						#{options[:more] == true ? more_modal : ""}
					</div>
				}
			else
				result = %{
					#{modified_value}
					#{options[:more] == true ? more_modal : ""}
				}
			end

			return result.html_safe
		end

		# *********************************************************************
		# Integer
		# *********************************************************************

		def self.integer(value, options = {})
			return "" if value.blank?

			# Format
			result = value.to_i.to_s
			result += " " + options[:unit].to_s if options[:unit]
			return result
		end

		# *********************************************************************
		# Float
		# *********************************************************************

		def self.float(value, options = {})
			return "" if value.blank?

			# Locale
			if options[:locale]
				locale = options[:locale]
			else
				locale = :cs
			end

			# Format
			result = @template.number_with_delimiter(value.to_f, locale: locale) 
			result += " " + options[:unit].to_s if options[:unit]
			return result
		end

		# *********************************************************************
		# Double
		# *********************************************************************

		def self.double(value, options = {})
			return "" if value.blank?

			# Locale
			if options[:locale]
				locale = options[:locale]
			else
				locale = :cs
			end

			# Format
			result = @template.number_with_delimiter(value.to_f, locale: locale) 
			result += " " + options[:unit].to_s if options[:unit]
			return result
		end

		# *********************************************************************
		# Currency
		# *********************************************************************

		def self.currency(value, options = {})
			return "" if value.blank?

			# Locale
			if options[:locale]
				locale = options[:locale]
			elsif options[:object] && options[:object].respond_to?(:currency_as_locale)
				locale = options[:object].currency_as_locale
			else
				locale = :cs
			end

			return @template.number_to_currency(value, locale: locale).to_s
		end

		# *********************************************************************
		# URL
		# *********************************************************************

		def self.url(value, options = {})
			return "" if value.blank?

			# Label
			if options[:label]
				label = options[:label]
			else
				label = value.to_s
			end
			label = label[7..-1] if label.start_with?("http://")
			label = label[8..-1] if label.start_with?("https://")
			
			# Target
			if options[:target]
				target = options[:target]
			else
				target = "_self"
			end
			
			return @template.link_to(label, value.to_s, target: target).to_s
		end


	end
end