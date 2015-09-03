# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - datepicker
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder

		def datepicker_row(name, options = {})
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# Java Script
			js = ""
			js += "function datepicker_#{hash}_ready()\n"
			js += "{\n"
			js += "	$('#datepicker_#{hash}').pikaday({ \n"
			js += "		firstDay: 1,\n"
			js += "		format: 'YYYY-MM-DD',\n"
			js += "		i18n: {\n"
			js += "			previousMonth : '#{I18n.t("views.calendar.prev_month")}',\n"
			js += "			nextMonth     : '#{I18n.t("views.calendar.next_month")}',\n"
			js += "			months        : ['#{I18n.t("views.calendar.months.january")}','#{I18n.t("views.calendar.months.february")}','#{I18n.t("views.calendar.months.march")}','#{I18n.t("views.calendar.months.april")}','#{I18n.t("views.calendar.months.may")}','#{I18n.t("views.calendar.months.june")}','#{I18n.t("views.calendar.months.july")}','#{I18n.t("views.calendar.months.august")}','#{I18n.t("views.calendar.months.september")}','#{I18n.t("views.calendar.months.october")}','#{I18n.t("views.calendar.months.november")}','#{I18n.t("views.calendar.months.december")}'],\n"
			js += "			weekdays      : ['#{I18n.t("views.calendar.days.sunday")}','#{I18n.t("views.calendar.days.monday")}','#{I18n.t("views.calendar.days.tuesday")}','#{I18n.t("views.calendar.days.wednesday")}','#{I18n.t("views.calendar.days.thursday")}','#{I18n.t("views.calendar.days.friday")}','#{I18n.t("views.calendar.days.saturday")}'],\n"
			js += "			weekdaysShort : ['#{I18n.t("views.calendar.short_days.sunday")}','#{I18n.t("views.calendar.short_days.monday")}','#{I18n.t("views.calendar.short_days.tuesday")}','#{I18n.t("views.calendar.short_days.wednesday")}','#{I18n.t("views.calendar.short_days.thursday")}','#{I18n.t("views.calendar.short_days.friday")}','#{I18n.t("views.calendar.short_days.saturday")}']\n"
			js += "		}\n"
			js += "	});\n"
			js += "}\n"
			js += "$(document).ready(datepicker_#{hash}_ready);\n"
			js += "$(document).on('page:load', datepicker_#{hash}_ready);\n"
			
			# CSS
			css = ""
			css += ".pika-single table thead { background: none; }\n"
			css += ".pika-single table thead th, .pika-single table tbody td { border: 0; }\n"
			css += ".is-selected .pika-button { background: #33aaff; border-radius: 0; }\n"
			css += ".pika-button:hover { background: #616161 !important; border-radius: 0 !important; }\n"

			# Options
			options[:id] = "datepicker_#{hash}"

			# Datepicker
			result = ""
			result += @template.javascript_tag(js)
			result += "<style>" + css + "</style>"
			result += text_input_row(name, :text_field, options)

			return result.html_safe
		end

	end
end