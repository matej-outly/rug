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
				result = ""
				
				# Unique hash
				hash = Digest::SHA1.hexdigest(section_name.to_s)

				# Library JS
				result += @template.javascript_tag(%{

					function RugFormConditionalSection(hash, options)
					{
						this.hash = hash;
						this.conditionalSection = $('#conditional-section-' + hash);
						this.readyInProgress = true;
						this.options = (typeof options !== 'undefined' ? options : {});
					}
					RugFormConditionalSection.prototype = {
						constructor: RugFormConditionalSection,
						interpret: function(value)
						{
							eval('var conditionRule = (' + this.options.conditionRule + ');');
							if (conditionRule) {
								if (this.readyInProgress) {
									this.conditionalSection.show();
								} else {
									this.conditionalSection.slideDown();
								}
							} else {
								if (this.readyInProgress) {
									this.conditionalSection.hide();
								} else {
									this.conditionalSection.slideUp();
								}
							}
							this.readyInProgress = false;
						},
						ready: function()
						{
							var _this = this;
							this.conditionalSection.hide();
							$('[name="' + _this.options.conditionName + '"]').on('change', function(e) {
								var __this = $(this);
								if (__this.is(':radio')) {
									if (__this.is(':checked')) {
										_this.interpret(__this.val());
									}
								} else {
									_this.interpret(__this.val());
								}
							}).trigger('change');
						}
					}
				})

				# Application JS
				result += @template.javascript_tag(%{
					var rug_form_conditional_section_#{hash} = null;
					$(document).ready(function() {
						rug_form_conditional_section_#{hash} = new RugFormConditionalSection('#{hash}', {
							conditionName: '#{object.class.model_name.param_key}[#{condition_name.to_s}]',
							conditionRule: '#{condition_rule.to_s}'
						});
						rug_form_conditional_section_#{hash}.ready();
					});
				})
				
				# Section
				result += @template.content_tag(:div, { :id => "conditional-section-#{hash}" }, &block)
				
				return result.html_safe
			end

		end
#	end
end