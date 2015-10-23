# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug table builder column definition - file types
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class TableBuilder
		class Columns

		protected

			# *********************************************************************
			# File
			# *********************************************************************

			def validate_file_options(column_spec)
				return true
			end


			def render_file(column, object)
				value = object.send(column)
				if value.exists?
					return "#{I18n.t("general.bool_yes")} - <a href=\"#{value.url}\">#{I18n.t("general.action.download")}</a>".html_safe
				else
					return I18n.t("general.bool_no")
				end
			end

			# *********************************************************************
			# Picture
			# *********************************************************************

			def validate_picture_options(column_spec)
				return column_spec.key?(:thumb_style)
			end

			def render_picture(column, object)
				value = object.send(column)
				if value.exists?
					return "<img src=\"#{value.url(@columns[column][:thumb_style])}\" />".html_safe
				else
					return I18n.t("general.bool_no")
				end
			end

		end
	end
end