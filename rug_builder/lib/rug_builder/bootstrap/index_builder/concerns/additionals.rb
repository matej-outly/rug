# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug index builder
# *
# * Author: Matěj Outlý
# * Date  : 7. 8. 2017
# *
# *****************************************************************************

module RugBuilder
#module Bootstrap
	class IndexBuilder
		module Concerns
			module Additionals extend ActiveSupport::Concern

				def pagination
					@template.paginate(@objects)
				end

				def summary
					result = %{
						<div class="summary">
							#{I18n.t("general.shown").upcase_first}: #{@objects.length}#{(self.model_class.respond_to?(:count) ? ("/" + self.model_class.count.to_s) : "")}
						</div>
					}
					return result.html_safe
				end

			end
		end
	end
#end
end