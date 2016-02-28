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
			
			# Options
			options[:id] = "date_picker_#{hash}"

			# Field
			result = ""
			result += @template.javascript_tag(js)
			result += text_input_row(name, :text_field, options)

			return result.html_safe
		end

		def time_picker_row(name, options = {})
			
			# Unique hash
			hash = Digest::SHA1.hexdigest(name.to_s)

			# Value
			value = object.send(name)
			if !value.blank?
				value = value.strftime("%k:%M")
			end

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

			# Options
			options[:id] = "time_picker_#{hash}"
			options[:value] = value
			
			# Field
			result = ""
			result += @template.javascript_tag(js)
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
			if !value.blank?
				value = value.strftime("%Y-%m-%d %k:%M")
			end
			
			# Field options
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input"

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
			
			result += @template.javascript_tag(js)
			
			# Container
			result += "<div id=\"datetime_picker_#{hash}\" class=\"prepend field #{( object.errors[name].size > 0 ? "danger" : "")}\">"
			
			# Inputs
			result += "<div class=\"row\">"
			result += "<div class=\"six columns field-item\">"
			result += "<span class=\"adjoined\">#{label_date.upcase_first}</span>"
			result += @template.text_field_tag(nil, nil, class: klass.dup.concat(["date", "normal"]).join(" "))
			result += "</div>"

			result += "<div class=\"six columns field-item\">"
			result += "<span class=\"adjoined\">#{label_time.upcase_first}</span>"
			result += @template.text_field_tag(nil, nil, class: klass.dup.concat(["time", "normal"]).join(" "))
			result += "</div>"
			result += "</div>"

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

		def duration_row(name, options = {})
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
			label_days = (options[:label_days] ? options[:label_days] : I18n.t("general.attribute.duration.days"))
			label_hours = (options[:label_hours] ? options[:label_hours] : I18n.t("general.attribute.duration.hours"))
			label_minutes = (options[:label_minutes] ? options[:label_minutes] : I18n.t("general.attribute.duration.minutes"))
			label_seconds = (options[:label_seconds] ? options[:label_seconds] : I18n.t("general.attribute.duration.seconds"))
			
			# Part values
			value = object.send(name)
			if !value.blank?
				value = value.strftime("%Y-%m-%d %k:%M:%S")
			end

			# Field options
			klass = []
			klass << options[:class] if !options[:class].nil?
			klass << "text input"
			
			# Java Script
			js = ""
			js += "function duration_#{hash}_days(date)\n"
			js += "{\n"
			js += "	var date = new Date(date);\n"
			js += "	var start = new Date(date.getFullYear(), 0, 1);\n"
			js += "	return Math.floor((date - start) / (1000 * 60 * 60 * 24));\n"
			js += "}\n"
			js += "function duration_#{hash}_date(days)\n"
			js += "{\n"
			js += "	var start = new Date(2000, 0, 2);\n"
			js += "	var date = new Date(start);\n"
			js += "	date.setDate(start.getDate() + parseInt(days));\n"
			js += "	return date.toISOString().split('T')[0];\n"
			js += "}\n"
			js += "function duration_#{hash}_update_inputs()\n"
			js += "{\n"
			js += "	var date_and_time = $('#duration_#{hash} .datetime').val().split(' ').filter(function(item){ return item != '' });\n"
			js += "	if (date_and_time.length >= 2) {\n"
			js += "		var days = duration_#{hash}_days(date_and_time[0]);\n"
			js += "		var hours_and_minutes_and_seconds = date_and_time[1].split(':');\n"
			js += " 	$('#duration_#{hash} .days').val(days);"
			js += " 	$('#duration_#{hash} .hours').val(hours_and_minutes_and_seconds[0]);"
			js += "		$('#duration_#{hash} .minutes').val(hours_and_minutes_and_seconds[1]);\n"
			js += "		$('#duration_#{hash} .seconds').val(hours_and_minutes_and_seconds[2]);\n"
			js += "	} else {\n"
			js += " 	$('#duration_#{hash} .days').val('');"
			js += " 	$('#duration_#{hash} .hours').val('');"
			js += "		$('#duration_#{hash} .minutes').val('');\n"
			js += "		$('#duration_#{hash} .seconds').val('');\n"
			js += "	}\n"
			js += "}\n"
			js += "function duration_#{hash}_update_datetime()\n"
			js += "{\n"
			js += "	var days = parseInt($('#duration_#{hash} .days').val());\n"
			js += "	var hours = parseInt($('#duration_#{hash} .hours').val());\n"
			js += "	var minutes = parseInt($('#duration_#{hash} .minutes').val());\n"
			js += "	var seconds = parseInt($('#duration_#{hash} .seconds').val());\n"
			js += "	if (!(isNaN(days) && isNaN(hours) && isNaN(minutes) && isNaN(seconds))) {\n"
			js += "		days = !isNaN(days) ? days : 0;\n"
			js += "		hours = !isNaN(hours) ? hours : 0;\n"
			js += "		minutes = !isNaN(minutes) ? minutes : 0;\n"
			js += "		seconds = !isNaN(seconds) ? seconds : 0;\n"
			js += "		$('#duration_#{hash} .datetime').val(duration_#{hash}_date(days) + ' ' + hours.toString() + ':' + minutes.toString() + ':' + seconds.toString());\n"
			js += "	} else {\n"
			js += "		$('#duration_#{hash} .datetime').val('');\n"
			js += "	}\n"
			js += "}\n"
			js += "function duration_#{hash}_ready()\n"
			js += "{\n"
			js += "	$('#duration_#{hash} .days').change(duration_#{hash}_update_datetime);\n"
			js += "	$('#duration_#{hash} .hours').change(duration_#{hash}_update_datetime);\n"
			js += "	$('#duration_#{hash} .minutes').change(duration_#{hash}_update_datetime);\n"
			js += "	$('#duration_#{hash} .seconds').change(duration_#{hash}_update_datetime);\n"
			js += "	duration_#{hash}_update_inputs();\n"
			js += "}\n"
			js += "$(document).ready(duration_#{hash}_ready);\n"
			js += "$(document).on('page:load', duration_#{hash}_ready);\n"
			
			result += @template.javascript_tag(js)
			
			# Container
			result += "<div id=\"duration_#{hash}\" class=\"append field #{( object.errors[name].size > 0 ? "danger" : "")}\">"

			# Inputs
			result += "<div class=\"row\">"
			if options[:days] != false
				result += "<div class=\"three columns field-item\">"
				result += @template.number_field_tag(nil, nil, class: klass.dup.concat(["days", "normal"]).join(" "), min: 0)
				result += "<span class=\"adjoined\">#{label_days.downcase_first}</span>"
				result += "</div>"
			end

			if options[:hours] != false
				result += "<div class=\"three columns field-item\">"
				result += @template.number_field_tag(nil, nil, class: klass.dup.concat(["hours", "normal"]).join(" "), min: 0, max: 23)
				result += "<span class=\"adjoined\">#{label_hours.downcase_first}</span>"
				result += "</div>"
			end

			if options[:minutes] != false
				result += "<div class=\"three columns field-item\">"
				result += @template.number_field_tag(nil, nil, class: klass.dup.concat(["minutes", "normal"]).join(" "), min: 0, max: 59)
				result += "<span class=\"adjoined\">#{label_minutes.downcase_first}</span>"
				result += "</div>"
			end

			if options[:seconds] != false
				result += "<div class=\"three columns field-item\">"
				result += @template.number_field_tag(nil, nil, class: klass.dup.concat(["seconds", "normal"]).join(" "), min: 0, max: 59)
				result += "<span class=\"adjoined\">#{label_seconds.downcase_first}</span>"
				result += "</div>"
			end
			result += "</div>"

			# Hidden fields
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