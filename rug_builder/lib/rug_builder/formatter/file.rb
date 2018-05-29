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
				
				# Content type
				content_type = options[:object].send(options[:column].to_s + "_content_type").to_s # Will not work with templater...
				
				# Icon
				icon = "file"
				icon = "file-image" if content_type.starts_with?("image/")
				icon = "file-video" if content_type.starts_with?("video/")
				icon = "file-audio" if content_type.starts_with?("audio/")
				icon = "file-pdf" if ["application/pdf"].include?(content_type)
				icon = "file-word" if ["application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"].include?(content_type)
				icon = "file-excel" if ["application/excel", "application/x-excel", "application/x-msexcel", "application/vnd.ms-excel"].include?(content_type)
				icon = "file-powerpoint" if ["application/vnd.ms-powerpoint"].include?(content_type)
				icon = "file-archive" if ["application/x-bzip", "application/x-bzip2", "application/x-gzip", "multipart/x-gzip", "application/x-compress", "application/x-compressed", "application/x-zip-compressed", "application/zip", "multipart/x-zip"].include?(content_type)

				# File name / truncate
				if options[:file_name] != false
					file_name = value.original_filename
					file_name = file_name.to_s.truncate(options[:truncate].is_a?(Hash) ? options[:truncate] : {}) if !options[:truncate].nil? && options[:truncate] != false
				else
					file_name = ""
				end

				result = %{
					<#{ options[:download] == true ? "a href=\"" + value.url + "\"" : "div" } #{ options[:target] ? "target=\"" + options[:target] + "\"" : "" } class="file-preview">
						#{ options[:picture] != false && content_type.starts_with?("image/") ? picture(value, options) : ""}
						<span class="inner-box">#{RugBuilder::IconBuilder.new(@template).render(icon)}#{file_name}</span>
					</#{ options[:download] == true ? "a" : "div"}>
				}
				
				return result.html_safe
			else
				return ""
			end
		end

		# *********************************************************************
		# Picture
		# *********************************************************************

		def self.picture(value, options = {})
			
			# Styles
			thumb_style = options[:thumb_style] ? options[:thumb_style] : :original
			full_style = options[:full_style] ? options[:full_style] : :original
			
			if value.exists?
				if options[:force_no_cache] == true
					picture_tag = "<img src=\"#{value.url(thumb_style).gsub(/\?[0-9]*$/, "?" + Time.now.to_i.to_s)}\" />".html_safe
				else
					picture_tag = "<img src=\"#{value.url(thumb_style)}\" />".html_safe
				end
				if options[:fancybox] == true
					return ("<a href=\"#{value.url(full_style)}\" class=\"fancybox\" rel=\"pictures\">" + picture_tag + "</a>").html_safe
				else
					return picture_tag
				end
			else
				return ""
			end
		end

	end
end