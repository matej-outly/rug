# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - datetime
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
	class FormBuilder < ActionView::Helpers::FormBuilder

		def date_picker_row(name, options = {})
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# Java Script
			js = ""
			js += "function date_picker_#{hash}_ready()\n"
			js += "{\n"
			js += "	$('#date_picker_#{hash}').pikaday({ \n"
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
			js += "$(document).ready(date_picker_#{hash}_ready);\n"
			js += "$(document).on('page:load', date_picker_#{hash}_ready);\n"
			
			# CSS
			css = ""
			css += ".pika-single.is-bound { font-family: inherit; border: 1px solid #d8d8d8 !important; -moz-border-radius: 4px; -webkit-border-radius: 4px; border-radius: 4px; box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2) !important; }\n"
			css += ".pika-single table thead { background: none; }\n"
			css += ".pika-single table thead th, .pika-single table tbody td { border: 0; }\n"
			css += ".is-selected .pika-button { background: #33aaff; border-radius: 0; }\n"
			css += ".pika-button:hover { background: #616161 !important; border-radius: 0 !important; }\n"

			# Options
			options[:id] = "date_picker_#{hash}"

			# Datepicker
			result = ""
			result += @template.javascript_tag(js)
			result += "<style>" + css + "</style>"
			result += text_input_row(name, :text_field, options)

			return result.html_safe
		end

		def time_picker_row(name, options = {})
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# Java Script
			js = ""
			js += "function time_picker_#{hash}_ready()\n"
			js += "{\n"
			js += "	$('#time_picker_#{hash}').clockpicker({\n"
			js += "		placement: 'bottom',\n"
			js += "		align: 'left',\n"
			js += "		autoclose: true\n"
			js += "	});\n"
			js += "}\n"
			js += "$(document).ready(time_picker_#{hash}_ready);\n"
			js += "$(document).on('page:load', time_picker_#{hash}_ready);\n"
			
			# CSS
			css = ""
			css += ".clockpicker-popover { border: 1px solid #d8d8d8; -moz-border-radius: 4px; -webkit-border-radius: 4px; border-radius: 4px; box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2); }\n"
			css += ".clockpicker-popover.bottom { margin-top: 0; }\n"
			css += ".clockpicker-popover > .arrow { display: none; }\n"

			# Options
			options[:id] = "time_picker_#{hash}"

			# Datepicker
			result = ""
			result += @template.javascript_tag(js)
			result += "<style>" + css + "</style>"
			result += text_input_row(name, :text_field, options)
			
			return result.html_safe
		end

		def datetime_picker_row(name, options = {})
			result = "<div class=\"element\">"

			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# Label
			if !options[:label].nil?
				if options[:label] != false
					result += label(name, options[:label])
				end
			else
				result += label(name)
			end

			# Part labels
			label_date = (options[:label_date] ? options[:label_date] : I18n.t("general.attribute.datetime.date"))
			label_time = (options[:label_time] ? options[:label_time] : I18n.t("general.attribute.datetime.time"))
			
			# Part values
			value = object.send(name)
			if value
				value = value.strftime("%Y-%m-%d %k:%M");
			end
			
			# Java Script
			js = ""
			js += "function datetime_picker_#{hash}_update_inputs()\n"
			js += "{\n"
			js += "	var date_and_time = $('#datetime_picker_#{hash} .datetime').val().split(' ');\n"
			js += " $('#datetime_picker_#{hash} .date').val(date_and_time[0]);"
			js += "	$('#datetime_picker_#{hash} .time').val(date_and_time[1]);\n"
			js += "}\n"
			js += "function datetime_picker_#{hash}_update_datetime()\n"
			js += "{\n"
			js += "	$('#datetime_picker_#{hash} .datetime').val($('#datetime_picker_#{hash} .date').val() + ' ' + $('#datetime_picker_#{hash} .time').val());\n"
			js += "}\n"
			js += "function datetime_picker_#{hash}_ready()\n"
			js += "{\n"
			js += "	$('#datetime_picker_#{hash} .date').pikaday({ \n"
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
			js += "	$('#datetime_picker_#{hash} .time').clockpicker({\n"
			js += "		placement: 'bottom',\n"
			js += "		align: 'left',\n"
			js += "		autoclose: true\n"
			js += "	});\n"
			js += "	$('#datetime_picker_#{hash} .date').on('change', datetime_picker_#{hash}_update_datetime);\n"
			js += "	$('#datetime_picker_#{hash} .time').on('change', datetime_picker_#{hash}_update_datetime);\n"
			js += "	datetime_picker_#{hash}_update_inputs();\n"
			js += "}\n"
			js += "$(document).ready(datetime_picker_#{hash}_ready);\n"
			js += "$(document).on('page:load', datetime_picker_#{hash}_ready);\n"
			
			# CSS
			css = ""
			
			# CSS date
			css += ".pika-single.is-bound { font-family: inherit; border: 1px solid #d8d8d8 !important; -moz-border-radius: 4px; -webkit-border-radius: 4px; border-radius: 4px; box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2) !important; }\n"
			css += ".pika-single table thead { background: none; }\n"
			css += ".pika-single table thead th, .pika-single table tbody td { border: 0; }\n"
			css += ".is-selected .pika-button { background: #33aaff; border-radius: 0; }\n"
			css += ".pika-button:hover { background: #616161 !important; border-radius: 0 !important; }\n"

			# CSS time
			css += ".clockpicker-popover { border: 1px solid #d8d8d8; -moz-border-radius: 4px; -webkit-border-radius: 4px; border-radius: 4px; box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2); }\n"
			css += ".clockpicker-popover.bottom { margin-top: 0; }\n"
			css += ".clockpicker-popover > .arrow { display: none; }\n"
			
			# JS + CSS
			result += @template.javascript_tag(js)
			result += "<style>" + css + "</style>"

			# Container
			result += "<div id=\"datetime_picker_#{hash}\" class=\"field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Inputs
			result += @template.text_field_tag(nil, nil, class: "text input normal date", placeholder: label_date)
			result += @template.text_field_tag(nil, nil, class: "text input normal time", placeholder: label_time)
			
			# Hidden field
			result += @template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value, class: "datetime")

			# Container end
			result += "</div>"
			
			# Errors
			if object.errors[name].size > 0
				result += @template.content_tag(:span, object.errors[name][0], :class => "danger label")
			end

			result += "</div>"
			return result.html_safe
		end

	end
end