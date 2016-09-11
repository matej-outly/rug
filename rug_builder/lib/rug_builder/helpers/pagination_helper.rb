# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 20. 7. 2015
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module PaginationHelper

			def paginate_more(collection, selector, options = {})
				return "" if !collection

				# Path
				if options[:path]
					url = URI.parse(options[:path].is_a?(Proc) ? options[:path].call : method(options[:path].to_sym).call)
				else
					url = URI.parse(request.original_url)
				end

				# Param name
				if options[:param_name]
					param_name = options[:param_name].to_sym
				else
					param_name = :page
				end

				# Current page
				current_page = params[param_name].to_i if params[param_name]
				current_page = 1 if current_page.blank?
				
				# Modify URL
				url_params = url.params
				url_params[param_name] = current_page + 1
				url.params = url_params

				# JavaScript
				js = ""
				js += "function pagination_more_ready()\n"
				js += "{\n"
				js += "	if (parseInt($('.pagination_more').data('pages')) <= 1) {\n"
				js += "		$('.pagination_more').addClass('done');\n"
				js += "	}\n"
				js += "	$('.pagination_more').on('click', function(e) {\n"
				js += "		e.preventDefault();\n"
				js += "		var _this = $(this);\n"
				js += "		if (!_this.hasClass('loading') && !_this.hasClass('done')) {\n"
				js += "			var url = _this.attr('href');\n"
				js += "			var page = parseInt(_this.data('page'));\n"
				js += "			var total_pages = parseInt(_this.data('pages'));\n"
				js += "			_this.addClass('loading');\n"
				js += "			$.ajax({\n"
				js += "				url: url,\n"
				js += "				dataType: 'html',\n"
				js += "				type: 'GET',\n"
				js += "				success: function(callback) \n"
				js += "				{\n"
				js += "					var new_html = $(callback).find('#{selector}').html();\n"
				js += "					$('#{selector}').append(new_html);\n"
				js += "					_this.attr('href', url.replace('#{param_name.to_s}=' + page, '#{param_name.to_s}=' + (page + 1)));\n"
				js += "					_this.data('page', page + 1);\n"
				js += "					if (page >= total_pages) {\n"
				js += "						_this.addClass('done');\n"
				js += "					}\n"
				js += "					_this.removeClass('loading');\n"
				js += "				},\n"
				js += "				error: function(callback) \n"
				js += "				{\n"
				js += "					_this.removeClass('loading');\n"
				js += "					console.log('error');\n"
				js += "				}\n"
				js += "			});\n"
				js += "		}\n"
				js += "	});\n"
				js += "}\n"
				js += "$(document).ready(pagination_more_ready);\n"
				js += "$(document).on('page:load', pagination_more_ready);\n"

				output = ""
				output += javascript_tag(js)
				output += link_to(I18n.t("views.pagination_more.more").html_safe, url.to_s, class: "pagination_more", data: { page: (current_page + 1), pages: collection.total_pages })

				# Result
				return output.html_safe
			end

		end
	end
end