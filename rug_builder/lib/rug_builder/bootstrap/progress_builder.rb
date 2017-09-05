# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug progress builder
# *
# * Author: Matěj Outlý
# * Date  : 20. 7. 2016
# *
# *****************************************************************************

module RugBuilder
#	module Bootstrap
		class ProgressBuilder

			#
			# Render progress 
			#
			def self.render(progress, options = {})
				options = options.nil? ? {} : options
				style = options[:style] ? options[:style] : "primary"
				
				# Normalize progress value
				progress = progress.to_i
				progress = 0 if progress < 0
				progress = 100 if progress > 100

				if !progress.blank?
					result = %{
						<div class="#{options[:class] ? options[:class] : ""}">
							#{options[:label_left] ? "<span class=\"progress-label-left\">" + options[:label_left].to_s + "</span>" : ""}
							#{options[:label_right] ? "<span class=\"progress-label-right\">" + options[:label_right].to_s + "</span>" : ""}
							<div class="progress #{options[:progress_class] ? options[:progress_class] : ""}">
								<div class="progress-bar progress-bar-#{style} progress-bar-striped" 
									role="progressbar"
									aria-valuenow="#{progress}" 
									aria-valuemin="0" 
									aria-valuemax="100" 
									style="width:#{progress}%; min-width: 2em;"
								>
									#{options[:title] ? "<span class=\"progress-bar-title\">" + options[:title].to_s + "</span>" : ""}
								</div>
							</div>
						</div>
					}
					return result.html_safe
				else
					return ""
				end
			end

		end
#	end
end




