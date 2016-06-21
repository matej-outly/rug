# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - file types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# File
		# *********************************************************************

		def self.file(value, options = {})
			if value.exists?
				return "#{I18n.t("general.attribute.boolean.bool_yes")} - <a href=\"#{value.url}\">#{I18n.t("general.action.download")}</a>".html_safe
			else
				return I18n.t("general.attribute.boolean.bool_no")
			end
		end

		# *********************************************************************
		# Picture
		# *********************************************************************

		def self.picture(value, options = {})
			
			# Thumb check
			if options[:thumb_style].nil?
				raise "Please, supply a thumb style."
			end

			# Full check
			if options[:fancybox] && options[:full_style].nil?
				raise "Please, supply a full style."
			end

			if value.exists?
				if options[:force_no_cache] == true
					picture_tag = "<img src=\"#{value.url(options[:thumb_style]).gsub(/\?[0-9]*$/, "?" + Time.now.to_i.to_s)}\" />".html_safe
				else
					picture_tag = "<img src=\"#{value.url(options[:thumb_style])}\" />".html_safe
				end
				if options[:fancybox] == true
					return ("<a href=\"#{value.url(options[:full_style])}\" class=\"fancybox\" rel=\"pictures\">" + picture_tag + "</a>").html_safe
				else
					return picture_tag
				end
			else
				return I18n.t("general.attribute.boolean.bool_no")
			end
		end

	end
end