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
				
				# Automatic URL - obsolete
				if options[:create_url] || options[:update_url]
					if options[:create_url] && object.new_record?
						options[:url] = RugSupport::PathResolver.new(self).resolve(options[:create_url])
					elsif options[:update_url] && !object.new_record?
						options[:url] = RugSupport::PathResolver.new(self).resolve(options[:update_url], object)
					else
						raise "Unable to resolve form URL."
					end
				end

				# Automatic URL
				if options[:create_path] || options[:update_path]
					if options[:create_path] && object.new_record?
						options[:url] = RugSupport::PathResolver.new(self).resolve(options[:create_path])
					elsif options[:update_path] && !object.new_record?
						options[:url] = RugSupport::PathResolver.new(self).resolve(options[:update_path], object)
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
					js_options = "{\n"
					if options[:ajax].is_a?(Hash)
						rb_options = options[:ajax]
						js_options += "flashSelector: '#{rb_options[:flash_selector]}',\n" if rb_options[:flash_selector]
						js_options += "modalSelector: '#{rb_options[:modal_selector]}',\n" if rb_options[:modal_selector]
						js_options += "successMessage: '#{rb_options[:success_message]}',\n" if rb_options[:success_message]
						js_options += "errorMessage: '#{rb_options[:error_message]}',\n" if rb_options[:error_message]
						js_options += "clearOnSubmit: #{rb_options[:clear_on_submit] == true ? "true" : "false"},\n" if !rb_options[:clear_on_submit].nil?
						js_options += "log: #{rb_options[:log] == true ? "true" : "false"},\n" if !rb_options[:log].nil?
						if rb_options[:on_success]
							os_options = rb_options[:on_success]
							js_options += "onSuccess: function(self, id) {\n"
							js_options += "self.hideForm(#{os_options[:hide_form][:timeout] ? os_options[:hide_form][:timeout] : ""});\n" if os_options[:hide_form]
							js_options += "self.toggleModal('#{os_options[:toggle_modal][:selector] ? os_options[:toggle_modal][:selector] : ""}');\n" if os_options[:toggle_modal]
							js_options += "self.reloadObject('#{os_options[:reload_object][:name] ? os_options[:reload_object][:name] : ""}', id);\n" if os_options[:reload_object]
							js_options += "},\n"
						end
					end
					js_options += "}\n"

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
