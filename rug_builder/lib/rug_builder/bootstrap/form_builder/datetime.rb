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
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Value
				value = object.send(name)
				if !value.blank?
					value = Date.parse(value) if !value.is_a?(Date) && !value.is_a?(DateTime) && !value.is_a?(Time)
					value = value.strftime(I18n.t("date.formats.default")) 
				end

				# Java Script
				result += @template.javascript_tag(%{
					function date_picker_#{hash}_ready()
					{
						#{date_js("#date_picker_#{hash}")}
					}
					$(document).ready(date_picker_#{hash}_ready);
				})
				
				# Options
				options[:id] = "date_picker_#{hash}"
				options[:value] = value

				# Field
				result += text_input_row(name, :text_field, options)

				return result.html_safe
			end

			def date_range_picker_row(name, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Value
				value = object.send(name)
				value_min = value && value[:min] ? value[:min] : nil
				value_max = value && value[:max] ? value[:max] : nil
				
				# Java Script
				result += @template.javascript_tag(%{
					function date_range_picker_#{hash}_update_backend()
					{
						var valueDates = $('#date_range_picker_#{hash} .dates').val().split(' - ');
						if (valueDates.length >= 2) {
							$('#date_range_picker_#{hash} .min').val(valueDates[0]);
							$('#date_range_picker_#{hash} .max').val(valueDates[1]);
						} else {
							$('#date_range_picker_#{hash} .min').val('');
							$('#date_range_picker_#{hash} .max').val('');
						}
					}
					function date_range_picker_#{hash}_update_frontend()
					{
						var valueMin = $('#date_range_picker_#{hash} .min').val();
						var valueMax = $('#date_range_picker_#{hash} .max').val();
						if (valueMin && valueMax) {
							$('#date_range_picker_#{hash} .dates').val(valueMin + ' - ' + valueMax);
						} else {
							$('#date_range_picker_#{hash} .dates').val('');
						}
					}
					function date_range_picker_#{hash}_ready()
					{
						#{date_range_js("#date_range_picker_#{hash} .dates")}
						$('#date_range_picker_#{hash} .dates').on('cancel.daterangepicker', function(ev, picker) {
							$(this).val('');
							date_range_picker_#{hash}_update_backend();
						});
						$('#date_range_picker_#{hash} .dates').on('change', date_range_picker_#{hash}_update_backend);
						date_range_picker_#{hash}_update_frontend();
					}
					$(document).ready(date_range_picker_#{hash}_ready);
				})
				
				# Field options
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?

				result += %{
					<div id="date_range_picker_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["dates"]))}
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}][min]", value_min, class: "min")}
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}][max]", value_max, class: "max")}
						#{errors(name, errors: options[:errors])}
					</div>
				}

				return result.html_safe
			end

			def time_picker_row(name, options = {})
				result = ""
				
				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Value
				value = object.send(name)
				if !value.blank?
					value = DateTime.parse(value) if !value.is_a?(DateTime) && !value.is_a?(Time)
					value = value.strftime(I18n.t("time.formats.hour_min")) 
				end

				# Java Script
				result += @template.javascript_tag(%{
					function time_picker_#{hash}_ready()
					{
						#{time_js("#time_picker_#{hash}")}
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
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Part labels
				label_date = (options[:label_date] ? options[:label_date] : I18n.t("general.attribute.datetime.date"))
				label_time = (options[:label_time] ? options[:label_time] : I18n.t("general.attribute.datetime.time"))
				
				# Part values
				value = object.send(name)
				if !value.blank?
					value = DateTime.parse(value) if !value.is_a?(DateTime) && !value.is_a?(Time)
					value = value.strftime(I18n.t("time.formats.default"))
				end
				
				# Java Script
				result += @template.javascript_tag(%{
					function datetime_picker_#{hash}_update_frontend()
					{
						var dateAndTime = $('#datetime_picker_#{hash} .datetime').val().split(' ');
						if (dateAndTime.length >= 4) {
							$('#datetime_picker_#{hash} .date').val(dateAndTime[0] + ' ' + dateAndTime[1] + ' ' + dateAndTime[2]);
							$('#datetime_picker_#{hash} .time').val(dateAndTime[dateAndTime.length-1]);
						}
					}
					function datetime_picker_#{hash}_update_backend()
					{
						$('#datetime_picker_#{hash} .datetime').val($('#datetime_picker_#{hash} .date').val() + ' ' + $('#datetime_picker_#{hash} .time').val());
					}
					function datetime_picker_#{hash}_ready()
					{
						#{date_js("#datetime_picker_#{hash} .date")}
						#{time_js("#datetime_picker_#{hash} .time")}
						$('#datetime_picker_#{hash} .date').on('change', datetime_picker_#{hash}_update_backend);
						$('#datetime_picker_#{hash} .time').on('change', datetime_picker_#{hash}_update_backend);
						datetime_picker_#{hash}_update_frontend();
					}
					$(document).ready(datetime_picker_#{hash}_ready);
				})
				
				# Field options
				klass = []
				klass << "form-control"
				klass << options[:class] if !options[:class].nil?

				result += %{
					<div id="datetime_picker_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
							#{@template.hidden_field_tag("#{object_name}[#{name.to_s}]", value, class: "datetime")}
							<div class="col-sm-6">
								#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
									#{options[:addon] ? "<div class=\"input-group-addon\">" + label_date.upcase_first + "</div>" : ""}
									#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["date"]))}
								#{options[:addon] ? "</div>" : ""}
							</div>
							<div class="col-sm-6">
								#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
									#{options[:addon] ? "<div class=\"input-group-addon\">" + label_time.upcase_first + "</div>" : ""}
									#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["time"]))}
								#{options[:addon] ? "</div>" : ""}
							</div>
							#{errors(name, errors: options[:errors], class: "col-sm-12")}
						</div>
					</div>
				}

				return result.html_safe
			end

			def datetime_range_picker_row(name, options = {})
				result = ""

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Part labels
				label_date = (options[:label_date] ? options[:label_date] : I18n.t("general.attribute.datetime_range.date"))
				label_from = (options[:label_from] ? options[:label_from] : I18n.t("general.attribute.datetime_range.from"))
				label_to = (options[:label_to] ? options[:label_to] : I18n.t("general.attribute.datetime_range.to"))
				
				# Part values
				value = object.send(name)
				value_date = value && value[:date] ? value[:date] : nil
				if !value_date.blank?
					value_date = Date.parse(value_date) if !value_date.is_a?(Date)
					value_date = value_date.strftime(I18n.t("date.formats.default")) 
				end
				value_from = value && value[:from] ? value[:from] : nil
				if !value_from.blank?
					value_from = DateTime.parse(value_from) if !value_from.is_a?(DateTime) && !value_from.is_a?(Time)
					value_from = value_from.strftime(I18n.t("date.formats.hour_min"))
				end
				value_to = value && value[:to] ? value[:to] : nil
				if !value_to.blank?
					value_to = DateTime.parse(value_to) if !value_to.is_a?(DateTime) && !value_to.is_a?(Time)
					value_to = value_to.strftime(I18n.t("date.formats.hour_min"))
				end
				
				# Java Script
				result += @template.javascript_tag(%{
					function datetime_range_picker_#{hash}_ready()
					{
						#{date_js("#datetime_range_picker_#{hash} .date")}
						#{time_js("#datetime_range_picker_#{hash} .from")}
						#{time_js("#datetime_range_picker_#{hash} .to")}
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
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] ? "<div class=\"input-group-addon\">" + label_date.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][date]", value_date, class: klass.dup.concat(["date"]))}
							#{options[:addon] ? "</div>" : ""}
						</div>
					}
				else
					result_date = %{
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}][date]", value_date)}
					}
				end

				if options[:from] != false
					result_from = %{
						<div class="col-sm-#{column_width}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] ? "<div class=\"input-group-addon\">" + label_from.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][from]", value_from, class: klass.dup.concat(["from"]))}
							#{options[:addon] ? "</div>" : ""}
						</div>
					}
				else
					result_from = %{
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}][from]", value_from)}
					}
				end

				if options[:to] != false
					result_to = %{
						<div class="col-sm-#{column_width}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{options[:addon] ? "<div class=\"input-group-addon\">" + label_to.upcase_first + "</div>" : ""}
								#{@template.text_field_tag("#{object_name}[#{name.to_s}][to]", value_to, class: klass.dup.concat(["to"]))}
							#{options[:addon] ? "</div>" : ""}
						</div>
					}
				else
					result_to = %{
						#{@template.hidden_field_tag("#{object_name}[#{name.to_s}][to]", value_to)}
					}
				end

				result += %{
					<div id="datetime_range_picker_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
							#{result_date}
							#{result_from}
							#{result_to}
							#{errors(name, errors: options[:errors], class: "col-sm-12")}
						</div>
					</div>
				}

				return result.html_safe
			end

			def duration_row(name, options = {})
				result = ""

				# Unique hash
				if options[:hash]
					hash = options[:hash]
				else
					hash = Digest::SHA1.hexdigest("#{object.class.to_s}_#{object.id.to_s}_#{name.to_s}")
				end

				# Part labels
				label_days = (options[:label_days] ? options[:label_days] : I18n.t("general.attribute.duration.days")) if options[:days] != false
				label_hours = (options[:label_hours] ? options[:label_hours] : I18n.t("general.attribute.duration.hours")) if options[:hours] != false
				label_minutes = (options[:label_minutes] ? options[:label_minutes] : I18n.t("general.attribute.duration.minutes")) if options[:minutes] != false
				label_seconds = (options[:label_seconds] ? options[:label_seconds] : I18n.t("general.attribute.duration.seconds")) if options[:seconds] != false
				
				# Part values
				value = object.send(name)
				value = value.strftime(I18n.t("time.formats.full")) if !value.blank?

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
				
				# Number of columns
				columns_count = 0
				columns_count += 1 if options[:days] != false
				columns_count += 1 if options[:hours] != false
				columns_count += 1 if options[:minutes] != false
				columns_count += 1 if options[:seconds] != false

				if options[:days] != false
					result_days = %{
						<div class="col-sm-#{12 / columns_count}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["days"]))}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_days.upcase_first + "</div>" : ""}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:hours] != false
					result_hours = %{
						<div class="col-sm-#{12 / columns_count}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["hours"]))}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_hours.upcase_first + "</div>" : ""}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:minutes] != false
					result_minutes = %{
						<div class="col-sm-#{12 / columns_count}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["minutes"]))}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_minutes.upcase_first + "</div>" : ""}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				if options[:seconds] != false
					result_seconds = %{
						<div class="col-sm-#{12 / columns_count}">
							#{options[:addon] != false ? "<div class=\"input-group\">" : ""}
								#{@template.text_field_tag(nil, nil, class: klass.dup.concat(["seconds"]))}
								#{options[:addon] != false ? "<div class=\"input-group-addon\">" + label_seconds.upcase_first + "</div>" : ""}
							#{options[:addon] != false ? "</div>" : ""}
						</div>
					}
				end

				result += %{
					<div id="duration_#{hash}" class="#{options[:form_group] != false ? "form-group" : ""} #{(has_error?(name, errors: options[:errors]) ? "has-error" : "")}">
						#{label_for(name, label: options[:label])}
						<div class="row">
							#{@template.hidden_field_tag("#{object.class.model_name.param_key}[#{name.to_s}]", value, class: "datetime")}
							#{options[:days] != false ? result_days : ""}
							#{options[:hours] != false ? result_hours : ""}
							#{options[:minutes] != false ? result_minutes : ""}
							#{options[:seconds] != false ? result_seconds : ""}
							#{errors(name, errors: options[:errors], class: "col-sm-12") }
						</div>
					</div>
				}

				return result.html_safe
			end

		protected

			def date_js(selector)
				return %{
					$('#{selector}').daterangepicker({ 
						singleDatePicker: true,
						showDropdowns: true,
						autoApply: true,
						autoUpdateInput: false,
						locale: {
							format: '#{I18n.t("date.formats.moment")}',
							applyLabel: '#{I18n.t("helpers.submit.ok")}',
							cancelLabel: '#{I18n.t("helpers.submit.cancel")}',
							daysOfWeek: [
								'#{I18n.t("date.abbr_day_names")[0]}',
								'#{I18n.t("date.abbr_day_names")[1]}',
								'#{I18n.t("date.abbr_day_names")[2]}',
								'#{I18n.t("date.abbr_day_names")[3]}',
								'#{I18n.t("date.abbr_day_names")[4]}',
								'#{I18n.t("date.abbr_day_names")[5]}',
								'#{I18n.t("date.abbr_day_names")[6]}'
							],
							monthNames: [
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
							firstDay: 1
						},
					});
					$('#{selector}').on('apply.daterangepicker', function(ev, picker) {
						$(this).val(picker.startDate.format('#{I18n.t("date.formats.moment")}'));
					});
					$('#{selector}').on('cancel.daterangepicker', function(ev, picker) {
						$(this).val('');
					});
				}
			end

			def date_range_js(selector)
				return %{
					$('#{selector}').daterangepicker({ 
						locale: {
							format: '#{I18n.t("date.formats.moment")}',
							applyLabel: '#{I18n.t("helpers.submit.ok")}',
							cancelLabel: '#{I18n.t("helpers.submit.cancel")}',
							separator: ' - ',
							daysOfWeek: [
								'#{I18n.t("date.abbr_day_names")[0]}',
								'#{I18n.t("date.abbr_day_names")[1]}',
								'#{I18n.t("date.abbr_day_names")[2]}',
								'#{I18n.t("date.abbr_day_names")[3]}',
								'#{I18n.t("date.abbr_day_names")[4]}',
								'#{I18n.t("date.abbr_day_names")[5]}',
								'#{I18n.t("date.abbr_day_names")[6]}'
							],
							monthNames: [
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
							firstDay: 1
						},
						cancelClass: 'btn-danger',
						applyClass: 'btn-primary',
					});
				}
			end

			def time_js(selector)
				return %{
					$('#{selector}').clockpicker({
						placement: 'bottom',
						align: 'left',
						autoclose: true
					});
				}
			end

		end
#	end
end