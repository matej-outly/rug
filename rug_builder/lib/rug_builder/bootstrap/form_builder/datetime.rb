# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - datetime TODO library JS code
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def date_picker_row(name, options = {})
				result = ""
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Java Script
				result += @template.javascript_tag(%{
					function date_picker_#{hash}_ready()
					{
						$('#date_picker_#{hash}').pikaday({ 
							firstDay: 1,
							format: 'YYYY-MM-DD',
							i18n: {
								previousMonth : '#{I18n.t("views.calendar.prev_month")}',
								nextMonth     : '#{I18n.t("views.calendar.next_month")}',
								months        : ['#{I18n.t("views.calendar.months.january")}','#{I18n.t("views.calendar.months.february")}','#{I18n.t("views.calendar.months.march")}','#{I18n.t("views.calendar.months.april")}','#{I18n.t("views.calendar.months.may")}','#{I18n.t("views.calendar.months.june")}','#{I18n.t("views.calendar.months.july")}','#{I18n.t("views.calendar.months.august")}','#{I18n.t("views.calendar.months.september")}','#{I18n.t("views.calendar.months.october")}','#{I18n.t("views.calendar.months.november")}','#{I18n.t("views.calendar.months.december")}'],
								weekdays      : ['#{I18n.t("views.calendar.days.sunday")}','#{I18n.t("views.calendar.days.monday")}','#{I18n.t("views.calendar.days.tuesday")}','#{I18n.t("views.calendar.days.wednesday")}','#{I18n.t("views.calendar.days.thursday")}','#{I18n.t("views.calendar.days.friday")}','#{I18n.t("views.calendar.days.saturday")}'],
								weekdaysShort : ['#{I18n.t("views.calendar.short_days.sunday")}','#{I18n.t("views.calendar.short_days.monday")}','#{I18n.t("views.calendar.short_days.tuesday")}','#{I18n.t("views.calendar.short_days.wednesday")}','#{I18n.t("views.calendar.short_days.thursday")}','#{I18n.t("views.calendar.short_days.friday")}','#{I18n.t("views.calendar.short_days.saturday")}']
							}
						});
					}
					$(document).ready(date_picker_#{hash}_ready);
				})
				
				# Options
				options[:id] = "date_picker_#{hash}"

				# Field
				result += text_input_row(name, :text_field, options)

				return result.html_safe
			end

			def time_picker_row(name, options = {})
				result = ""
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Value
				value = object.send(name)
				if !value.blank?
					value = DateTime.parse(value) if !value.is_a?(DateTime) && !value.is_a?(Time)
					value = value.strftime("%k:%M") 
				end

				# Java Script
				result += @template.javascript_tag(%{
					function time_picker_#{hash}_ready()
					{
						$('#time_picker_#{hash}').clockpicker({
							placement: 'bottom',
							align: 'left',
							autoclose: true
						});
					}
					$(document).ready(time_picker_#{hash}_ready);
				})

				# Options
				options[:id] = "time_picker_#{hash}"
				options[:value] = value
				
				# Field
				result += text_input_row(name, :text_field, options)
				
				return result.html_safe
			end

			def datetime_picker_row(name, options = {})
				result = ""

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Label
				result += label_for(name, options)

				# Part labels
				label_date = (options[:label_date] ? options[:label_date] : I18n.t("general.attribute.datetime.date"))
				label_time = (options[:label_time] ? options[:label_time] : I18n.t("general.attribute.datetime.time"))
				
				# Part values
				value = object.send(name)
				if !value.blank?
					value = DateTime.parse(value) if !value.is_a?(DateTime) && !value.is_a?(Time)
					value = value.strftime("%Y-%m-%d %k:%M")
				end
				
				# Java Script
				result += @template.javascript_tag(%{
					function datetime_picker_#{hash}_update_inputs()
					{
						var date_and_time = $('#datetime_picker_#{hash} .datetime').val().split(' ');
						$('#datetime_picker_#{hash} .date').val(date_and_time[0]);
						$('#datetime_picker_#{hash} .time').val(date_and_time[1]);
					}
					function datetime_picker_#{hash}_update_datetime()
					{
						$('#datetime_picker_#{hash} .datetime').val($('#datetime_picker_#{hash} .date').val() + ' ' + $('#datetime_picker_#{hash} .time').val());
					}
					function datetime_picker_#{hash}_ready()
					{
						$('#datetime_picker_#{hash} .date').pikaday({ 
							firstDay: 1,
							format: 'YYYY-MM-DD',
							i18n: {
								previousMonth : '#{I18n.t("views.calendar.prev_month")}',
								nextMonth     : '#{I18n.t("views.calendar.next_month")}',
								months        : ['#{I18n.t("views.calendar.months.january")}','#{I18n.t("views.calendar.months.february")}','#{I18n.t("views.calendar.months.march")}','#{I18n.t("views.calendar.months.april")}','#{I18n.t("views.calendar.months.may")}','#{I18n.t("views.calendar.months.june")}','#{I18n.t("views.calendar.months.july")}','#{I18n.t("views.calendar.months.august")}','#{I18n.t("views.calendar.months.september")}','#{I18n.t("views.calendar.months.october")}','#{I18n.t("views.calendar.months.november")}','#{I18n.t("views.calendar.months.december")}'],
								weekdays      : ['#{I18n.t("views.calendar.days.sunday")}','#{I18n.t("views.calendar.days.monday")}','#{I18n.t("views.calendar.days.tuesday")}','#{I18n.t("views.calendar.days.wednesday")}','#{I18n.t("views.calendar.days.thursday")}','#{I18n.t("views.calendar.days.friday")}','#{I18n.t("views.calendar.days.saturday")}'],
								weekdaysShort : ['#{I18n.t("views.calendar.short_days.sunday")}','#{I18n.t("views.calendar.short_days.monday")}','#{I18n.t("views.calendar.short_days.tuesday")}','#{I18n.t("views.calendar.short_days.wednesday")}','#{I18n.t("views.calendar.short_days.thursday")}','#{I18n.t("views.calendar.short_days.friday")}','#{I18n.t("views.calendar.short_days.saturday")}']
							}
						});
						$('#datetime_picker_#{hash} .time').clockpicker({
							placement: 'bottom',
							align: 'left',
							autoclose: true
						});
						$('#datetime_picker_#{hash} .date').on('change', datetime_picker_#{hash}_update_datetime);
						$('#datetime_picker_#{hash} .time').on('change', datetime_picker_#{hash}_update_datetime);
						datetime_picker_#{hash}_update_inputs();
					}
					$(document).ready(datetime_picker_#{hash}_ready);
				})
				
				# Field options
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?

				result += %{
					<div class="form-horizontal">
						<div id="datetime_picker_#{hash}" class="form-group #{(has_error?(name) ? "has-error" : "")}">
							#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value, class: "datetime")}
							<div class="col-sm-6">
								<div class="input-group">
									<div class="input-group-addon">#{label_date.upcase_first}</div>
									#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["date"]))}
								</div>
							</div>
							<div class="col-sm-6">
								<div class="input-group">
									<div class="input-group-addon">#{label_time.upcase_first}</div>
									#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["time"]))}
								</div>
							</div>
							#{errors(name, class: "col-sm-12")}
						</div>
					</div>
				}

				return result.html_safe
			end

			def datetime_range_picker_row(name, options = {})
				result = ""

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Label
				result += label_for(name, options)

				# Part labels
				label_date = (options[:label_date] ? options[:label_date] : I18n.t("general.attribute.datetime_range.date"))
				label_from = (options[:label_from] ? options[:label_from] : I18n.t("general.attribute.datetime_range.from"))
				label_to = (options[:label_to] ? options[:label_to] : I18n.t("general.attribute.datetime_range.to"))
				
				# Part values
				value = object.send(name)
				value_date = value && value[:date] ? value[:date] : nil
				value_from = value && value[:from] ? value[:from] : nil
				if !value_from.blank?
					value_from = value_from.strftime("%k:%M")
				end
				value_to = value && value[:to] ? value[:to] : nil
				if !value_to.blank?
					value_to = value_to.strftime("%k:%M")
				end
				
				# Java Script
				result += @template.javascript_tag(%{
					function datetime_range_picker_#{hash}_ready()
					{
						$('#datetime_range_picker_#{hash} .date').pikaday({ 
							firstDay: 1,
							format: 'YYYY-MM-DD',
							i18n: {
								previousMonth : '#{I18n.t("views.calendar.prev_month")}',
								nextMonth     : '#{I18n.t("views.calendar.next_month")}',
								months        : ['#{I18n.t("views.calendar.months.january")}','#{I18n.t("views.calendar.months.february")}','#{I18n.t("views.calendar.months.march")}','#{I18n.t("views.calendar.months.april")}','#{I18n.t("views.calendar.months.may")}','#{I18n.t("views.calendar.months.june")}','#{I18n.t("views.calendar.months.july")}','#{I18n.t("views.calendar.months.august")}','#{I18n.t("views.calendar.months.september")}','#{I18n.t("views.calendar.months.october")}','#{I18n.t("views.calendar.months.november")}','#{I18n.t("views.calendar.months.december")}'],
								weekdays      : ['#{I18n.t("views.calendar.days.sunday")}','#{I18n.t("views.calendar.days.monday")}','#{I18n.t("views.calendar.days.tuesday")}','#{I18n.t("views.calendar.days.wednesday")}','#{I18n.t("views.calendar.days.thursday")}','#{I18n.t("views.calendar.days.friday")}','#{I18n.t("views.calendar.days.saturday")}'],
								weekdaysShort : ['#{I18n.t("views.calendar.short_days.sunday")}','#{I18n.t("views.calendar.short_days.monday")}','#{I18n.t("views.calendar.short_days.tuesday")}','#{I18n.t("views.calendar.short_days.wednesday")}','#{I18n.t("views.calendar.short_days.thursday")}','#{I18n.t("views.calendar.short_days.friday")}','#{I18n.t("views.calendar.short_days.saturday")}']
							}
						});
						$('#datetime_range_picker_#{hash} .from').clockpicker({
							placement: 'bottom',
							align: 'left',
							autoclose: true
						});
						$('#datetime_range_picker_#{hash} .to').clockpicker({
							placement: 'bottom',
							align: 'left',
							autoclose: true
						});
					}
					$(document).ready(datetime_range_picker_#{hash}_ready);
				})
				
				# Field options
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?

				# Column width
				columns_count = (3 - [options[:date], options[:from], options[:to]].count(false))
				if columns_count > 0
					column_width = 12 / columns_count
				else
					column_width = 12
				end
				
				if options[:date] != false
					result_date = %{
						<div class="col-sm-#{column_width}">
							<div class="input-group">
								<div class="input-group-addon">#{label_date.upcase_first}</div>
								#{@template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][date]", value_date, class: klass.dup.concat(["date"]))}
							</div>
						</div>
					}
				else
					result_date = %{
						#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][date]", value_date)}
					}
				end

				if options[:from] != false
					result_from = %{
						<div class="col-sm-#{column_width}">
							<div class="input-group">
								<div class="input-group-addon">#{label_from.upcase_first}</div>
								#{@template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][from]", value_from, class: klass.dup.concat(["from"]))}
							</div>
						</div>
					}
				else
					result_from = %{
						#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][from]", value_from)}
					}
				end

				if options[:to] != false
					result_to = %{
						<div class="col-sm-#{column_width}">
							<div class="input-group">
								<div class="input-group-addon">#{label_to.upcase_first}</div>
								#{@template.text_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][to]", value_to, class: klass.dup.concat(["to"]))}
							</div>
						</div>
					}
				else
					result_to = %{
						#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}][to]", value_to)}
					}
				end

				result += %{
					<div class="form-horizontal">
						<div id="datetime_range_picker_#{hash}" class="form-group #{(has_error?(name) ? "has-error" : "")}">
							#{result_date}
							#{result_from}
							#{result_to}
							#{errors(name, class: "col-sm-12")}
						</div>
					</div>
				}

				return result.html_safe
			end

			def duration_row(name, options = {})
				result = ""

				# Unique hash
				hash = Digest::SHA1.hexdigest(name.to_s)

				# Label
				result += label_for(name, options)

				# Part labels
				label_days = (options[:label_days] ? options[:label_days] : I18n.t("general.attribute.duration.days"))
				label_hours = (options[:label_hours] ? options[:label_hours] : I18n.t("general.attribute.duration.hours"))
				label_minutes = (options[:label_minutes] ? options[:label_minutes] : I18n.t("general.attribute.duration.minutes"))
				label_seconds = (options[:label_seconds] ? options[:label_seconds] : I18n.t("general.attribute.duration.seconds"))
				
				# Part values
				value = object.send(name)
				value = value.strftime("%Y-%m-%d %k:%M:%S") if !value.blank?

				# Java Script
				result += @template.javascript_tag(%{
					function duration_#{hash}_days(date)
					{
						var date = new Date(date);
						var start = new Date(date.getFullYear(), 0, 1);
						return Math.floor((date - start) / (1000 * 60 * 60 * 24));
					}
					function duration_#{hash}_date(days)
					{
						var start = new Date(2000, 0, 2);
						var date = new Date(start);
						date.setDate(start.getDate() + parseInt(days));
						return date.toISOString().split('T')[0];
					}
					function duration_#{hash}_update_inputs()
					{
						var dateAndTime = $('#duration_#{hash} .datetime').val().split(' ').filter(function(item){ return item != '' });
						if (dateAndTime.length >= 2) {
							var days = duration_#{hash}_days(dateAndTime[0]);
							var hoursAndMinutesAndSeconds = dateAndTime[1].split(':');
							$('#duration_#{hash} .days').val(days);
							$('#duration_#{hash} .hours').val(hoursAndMinutesAndSeconds[0]);
							$('#duration_#{hash} .minutes').val(hoursAndMinutesAndSeconds[1]);
							$('#duration_#{hash} .seconds').val(hoursAndMinutesAndSeconds[2]);
						} else {
							$('#duration_#{hash} .days').val('');
							$('#duration_#{hash} .hours').val('');
							$('#duration_#{hash} .minutes').val('');
							$('#duration_#{hash} .seconds').val('');
						}
					}
					function duration_#{hash}_update_datetime()
					{
						var days = parseInt($('#duration_#{hash} .days').val());
						var hours = parseInt($('#duration_#{hash} .hours').val());
						var minutes = parseInt($('#duration_#{hash} .minutes').val());
						var seconds = parseInt($('#duration_#{hash} .seconds').val());
						if (!(isNaN(days) && isNaN(hours) && isNaN(minutes) && isNaN(seconds))) {
							days = !isNaN(days) ? days : 0;
							hours = !isNaN(hours) ? hours : 0;
							minutes = !isNaN(minutes) ? minutes : 0;
							seconds = !isNaN(seconds) ? seconds : 0;
							$('#duration_#{hash} .datetime').val(duration_#{hash}_date(days) + ' ' + hours.toString() + ':' + minutes.toString() + ':' + seconds.toString());
						} else {
							$('#duration_#{hash} .datetime').val('');
						}
					}
					function duration_#{hash}_ready()
					{
						$('#duration_#{hash} .days').change(duration_#{hash}_update_datetime);
						$('#duration_#{hash} .hours').change(duration_#{hash}_update_datetime);
						$('#duration_#{hash} .minutes').change(duration_#{hash}_update_datetime);
						$('#duration_#{hash} .seconds').change(duration_#{hash}_update_datetime);
						duration_#{hash}_update_inputs();
					}
					$(document).ready(duration_#{hash}_ready);
				})
				
				# Field options
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?
				
				# number of columns
				columns_count = 0
				columns_count += 1 if options[:days] != false
				columns_count += 1 if options[:hours] != false
				columns_count += 1 if options[:minutes] != false
				columns_count += 1 if options[:seconds] != false

				result_days = %{
					<div class="col-sm-#{12 / columns_count}">
						<div class="input-group">
							<div class="input-group-addon">#{label_days.upcase_first}</div>
							#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["days"]))}
						</div>
					</div>
				}

				result_hours = %{
					<div class="col-sm-#{12 / columns_count}">
						<div class="input-group">
							<div class="input-group-addon">#{label_hours.upcase_first}</div>
							#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["hours"]))}
						</div>
					</div>
				}

				result_minutes = %{
					<div class="col-sm-#{12 / columns_count}">
						<div class="input-group">
							<div class="input-group-addon">#{label_minutes.upcase_first}</div>
							#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["minutes"]))}
						</div>
					</div>
				}

				result_seconds = %{
					<div class="col-sm-#{12 / columns_count}">
						<div class="input-group">
							<div class="input-group-addon">#{label_seconds.upcase_first}</div>
							#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["seconds"]))}
						</div>
					</div>
				}

				result += %{
					<div class="form-horizontal">
						<div id="duration_#{hash}" class="form-group #{(has_error?(name) ? "has-error" : "")}">
							#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value, class: "datetime")}
							#{ options[:days] != false ? result_days : ""}
							#{ options[:hours] != false ? result_hours : ""}
							#{ options[:minutes] != false ? result_minutes : ""}
							#{ options[:seconds] != false ? result_seconds : ""}
							#{ errors(name, class: "col-sm-12") }
						</div>
					</div>
				}

				return result.html_safe
			end

		end
#	end
end