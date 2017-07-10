# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug chart builder TODO refactor JS to object
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
			# Time flexible line chart
			#
			def time_flexible_line_chart(path, options = {})
				return time_flexible_chart(:line, path, options)
			end

			#
			# Time flexible area chart
			#
			def time_flexible_area_chart(path, options = {})
				return time_flexible_chart(:area, path, options)
			end

		protected

			#
			# Time flexible chart
			#
			def time_flexible_chart(type, path, options = {})
				result = ""
				options = options.nil? ? {} : options
			
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
				
				# Google API
				result += @template.javascript_include_tag("https://www.google.com/jsapi")

				# Application JS
				result += @template.javascript_tag(%{
					var rug_chart_#{hash} = null;
					RugChart.setup({
						language: '#{I18n.locale.to_s}',
					});
					$(document).ready(function() {
						rug_chart_#{hash} = new RugChart('#{hash}', {
							id: '#{options[:id]}',
							path: '#{path}',
							type: '#{type}',
							i18n: {
								previousMonth : '#{I18n.t("views.calendar.previous_month")}',
								nextMonth     : '#{I18n.t("views.calendar.next_month")}',
								months        : [
									'#{I18n.t("date.month_names")[1]}',
									'#{I18n.t("date.month_names")[2]}',
									'#{I18n.t("date.month_names")[3]}',
									'#{I18n.t("date.month_names")[4]}',
									'#{I18n.t("date.month_names")[5]}',
									'#{I18n.t("date.month_names")[6]}',
									'#{I18n.t("date.month_names")[7]}',
									'#{I18n.t("date.month_names")[8]}',
									'#{I18n.t("date.month_names")[9]}',
									'#{I18n.t("date.month_names")[10]}',
									'#{I18n.t("date.month_names")[11]}',
									'#{I18n.t("date.month_names")[12]}'
								],
								weekdays      : [
									'#{I18n.t("date.day_names")[0]}',
									'#{I18n.t("date.day_names")[1]}',
									'#{I18n.t("date.day_names")[2]}',
									'#{I18n.t("date.day_names")[3]}',
									'#{I18n.t("date.day_names")[4]}',
									'#{I18n.t("date.day_names")[5]}',
									'#{I18n.t("date.day_names")[6]}'
								],
								weekdaysShort : [
									'#{I18n.t("date.abbr_day_names")[0]}',
									'#{I18n.t("date.abbr_day_names")[1]}',
									'#{I18n.t("date.abbr_day_names")[2]}',
									'#{I18n.t("date.abbr_day_names")[3]}',
									'#{I18n.t("date.abbr_day_names")[4]}',
									'#{I18n.t("date.abbr_day_names")[5]}',
									'#{I18n.t("date.abbr_day_names")[6]}'
								]
							}
						});
						rug_chart_#{hash}.ready();
					});
				})

				# HTML
				result += %{
					<div class="panel panel-default" id="chart-#{hash}">
						<div class="panel-body">
							<div class="row">
								<div class="col-sm-12">
									#{@template.send("#{type.to_s}_chart".to_sym, path + "?from=#{default_from.to_s}&to=#{default_to.to_s}", options)}
								</div>
								<div class="col-sm-3">
									#{@template.text_field_tag("chart_#{hash}_date_from", default_from.to_s, class: "form-control date-from")}
								</div>
								<div class="col-sm-3 col-sm-offset-6">
									#{@template.text_field_tag("chart_#{hash}_date_to", default_to.to_s, class: "form-control date-to")}
								</div>
							</div>
						</div>
					</div>
				}

				return result.html_safe
			end

		end
#	end
end