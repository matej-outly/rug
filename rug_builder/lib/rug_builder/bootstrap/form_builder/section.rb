# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder - section
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			def conditional_section(section_name, condition_name, condition_rule, &block)
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(section_name.to_s)

				# Java Script
				js = ""
				js += "var conditional_section_#{hash}_ready_in_progress = true;\n"
				
				js += "function conditional_section_#{hash}_interpret(value)\n"
				js += "{\n"
				js += "		console.log(value);\n"
				js += "		if (" + condition_rule + ") {\n"
				js += "			if (conditional_section_#{hash}_ready_in_progress) {\n"
				js += "				$('#conditional_section_#{hash}').show();\n"
				js += "			} else {\n"
				js += "				$('#conditional_section_#{hash}').slideDown();\n"
				js += "			}\n"
				js += "		} else {\n"
				js += "			if (conditional_section_#{hash}_ready_in_progress) {\n"
				js += "				$('#conditional_section_#{hash}').hide();\n"
				js += "			} else {\n"
				js += "				$('#conditional_section_#{hash}').slideUp();\n"
				js += "			}\n"
				js += "		}\n"
				js += "		conditional_section_#{hash}_ready_in_progress = false;\n"
				js += "}\n"

				js += "function conditional_section_#{hash}_ready()\n"
				js += "{\n"
				js += "	$('#conditional_section_#{hash}').hide();\n"
				js += "	$('[name=\\'#{object.class.model_name.param_key}[#{condition_name.to_s}]\\']').on('change', function(e) {\n"
				js += "		var _this = $(this);\n"
				js += "		if (_this.is(':radio')) {\n"
				js += "			if (_this.is(':checked')) {\n"
				js += "				conditional_section_#{hash}_interpret(_this.val());\n"
				js += "			}\n"
				js += "		} else {\n"
				js += "			conditional_section_#{hash}_interpret(_this.val());\n"
				js += "		}\n"
				js += "	}).trigger('change');\n"
				js += "}\n"
				js += "$(document).ready(conditional_section_#{hash}_ready);\n"
				js += "$(document).on('page:load', conditional_section_#{hash}_ready);\n"
				
				# Section
				result = ""
				result += @template.javascript_tag(js)
				result += @template.content_tag(:div, { :id => "conditional_section_#{hash}" }, &block)
				
				return result.html_safe
			end

		end
#	end
end