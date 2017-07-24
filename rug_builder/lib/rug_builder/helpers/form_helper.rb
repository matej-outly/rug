# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 28. 6. 2015
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module FormHelper

			def rug_form_for(object, options = {}, &block)
				result = ""

				# Builder
				options[:builder] = RugBuilder::FormBuilder
				
				# Automatic URL
				if options[:create_url] || options[:update_url]
					if options[:create_url] && object.new_record?
						options[:url] = RugSupport::PathResolver.new(self).resolve(options[:create_url])
					elsif options[:update_url] && !object.new_record?
						options[:url] = RugSupport::PathResolver.new(self).resolve(options[:update_url], object)
					else
						raise "Unable to resolve form URL."
					end
				end

				# Automatic instance
				if object.is_a?(Class)
					object = object.new
				end

				# Form itself
				result += form_for(object, options, &block)

				# Ajax form
				if options[:ajax] == true || options[:ajax].is_a?(Hash)
					
					# Options
					js_options = "{"
					if options[:ajax].is_a?(Hash)
						js_options += "flashSelector: '#{options[:ajax][:flash_selector]}', " if options[:ajax][:flash_selector]
						js_options += "modalSelector: '#{options[:ajax][:modal_selector]}', " if options[:ajax][:modal_selector]
						js_options += "successMessage: '#{options[:ajax][:success_message]}', " if options[:ajax][:success_message]
						js_options += "errorMessage: '#{options[:ajax][:error_message]}', " if options[:ajax][:error_message]
						js_options += "clearOnSubmit: #{options[:ajax][:clear_on_submit] == true ? "true" : "false"}, " if !options[:ajax][:clear_on_submit].nil?
						js_options += "behaviorOnSubmit: '#{options[:ajax][:behavior_on_submit]}', " if options[:ajax][:behavior_on_submit]
						js_options += "hideTimeout: '#{options[:ajax][:hide_timeout]}', " if options[:ajax][:hide_timeout]
						js_options += "copyToObject: '#{options[:ajax][:copy_to_object]}', " if options[:ajax][:copy_to_object]
						js_options += "redirectUrl: '#{options[:ajax][:redirect_url]}', " if options[:ajax][:redirect_url]
						js_options += "showUrl: '#{options[:ajax][:show_url]}', " if options[:ajax][:show_url]
						js_options += "showUrl: '#{options[:ajax][:show_url]}', " if options[:ajax][:show_url]
						js_options += "invisibleRecaptcha: #{options[:ajax][:invisible_recaptcha] == true ? "true" : "false"}, " if !options[:ajax][:invisible_recaptcha].nil?
						js_options += "logCallback: #{options[:ajax][:log_callback] == true ? "true" : "false"}, " if !options[:ajax][:log_callback].nil?
					end
					js_options += "}"

					result += javascript_tag(%{
						$(document).ready(function() {
							$("##{options[:html][:id]}").ajaxForm(#{js_options});
						});
					})
				end

				return result.html_safe
			end

		end
	end
end
