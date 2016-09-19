# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug chart builder
# *
# * Author: Matěj Outlý
# * Date  : 19. 9. 2016
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class ChartBuilder

			#
			# Constructor
			#
			def initialize(template)
				@template = template
			end

			#
			# Time flexible area chart
			#
			def time_flexible_area_chart(path, options = {})
				result = ""
			
				# ID check
				if options[:id].blank?
					raise "Please supply chart ID in options."
				end

				# Default range
				if options[:default_range]
					default_range = options[:default_range]
				else
					default_range = 1.year
				end

				# Default dates
				default_to = Date.today
				default_from =  Date.today - default_range

				# Unique hash
				hash = Digest::SHA1.hexdigest(options[:id].to_s)
				from_hash = Digest::SHA1.hexdigest(hash + "_from")
				to_hash = Digest::SHA1.hexdigest(hash + "_to")

				# Google API
				result += @template.javascript_include_tag("https://www.google.com/jsapi")

				# JavaScript
				js = ""

				# Chartkick config
				js += "Chartkick.configure({'language': '#{I18n.locale.to_s}'});\n"

				# Reload function
				js += "function time_flexible_area_chart_#{hash}_reload()\n"
				js += "{\n"
				js += "	var from_date = $('#date_picker_#{from_hash}').val();\n"
				js += "	var to_date = $('#date_picker_#{to_hash}').val();\n"
				js += "	var path = '#{path}';\n"
				js += "	var params = [];\n"
				js += "	if (from_date) {\n"
				js += "		params.push('from=' + from_date)\n"
				js += "	}\n"
				js += "	if (to_date) {\n"
				js += "		params.push('to=' + to_date)\n"
				js += "	}\n"
				js += "	var chart_options = Chartkick.charts['#{options[:id]}'].getOptions();\n"
				js += "	new Chartkick.AreaChart('#{options[:id]}', path + '?' + params.join('&'), chart_options);\n"
				js += "}\n"

				# Ready function
				js += "function time_flexible_area_chart_#{hash}_ready()\n"
				js += "{\n"
				js += "	$('#date_picker_#{from_hash}, #date_picker_#{to_hash}').pikaday({ \n"
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
				js += "	$('#date_picker_#{from_hash}, #date_picker_#{to_hash}').on('change', time_flexible_area_chart_#{hash}_reload);\n"
				js += "}\n"
				js += "$(document).ready(time_flexible_area_chart_#{hash}_ready);\n"

				# Add JavaScript to result
				result += @template.javascript_tag(js)

				# Panel
				result += "<div class=\"panel panel-default\">"
				result += "<div class=\"panel-body\">"

				# Chart
				result += @template.area_chart(path + "?from=#{default_from.to_s}&to=#{default_to.to_s}", options)

				# Row
				result += "<div class=\"row\">"
				
				# From
				result += "<div class=\"col-sm-3\">"
				result += @template.text_field_tag("time_flexible_area_chart_#{hash}_from", default_from.to_s, class: "form-control", id: "date_picker_#{from_hash}")
				result += "</div>"

				# To
				result += "<div class=\"col-sm-3 col-sm-offset-6\">"
				result += @template.text_field_tag("time_flexible_area_chart_#{hash}_to", default_to.to_s, class: "form-control", id: "date_picker_#{to_hash}")
				result += "</div>"
				
				# Row end
				result += "</div>"

				# Panel end
				result += "</div>"
				result += "</div>"

				return result.html_safe
			end

		end
#	end
end