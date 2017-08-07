# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug form builder
# *
# * Author: Matěj Outlý
# * Date  : 8. 3. 2015
# *
# *****************************************************************************

require "action_view"

# Parts
require "rug_builder/bootstrap/form_builder/button"
require "rug_builder/bootstrap/form_builder/checkbox"
require "rug_builder/bootstrap/form_builder/crop"
require "rug_builder/bootstrap/form_builder/datetime"
require "rug_builder/bootstrap/form_builder/dropzone"
require "rug_builder/bootstrap/form_builder/editable"
require "rug_builder/bootstrap/form_builder/errors"
require "rug_builder/bootstrap/form_builder/generic"
require "rug_builder/bootstrap/form_builder/label"
require "rug_builder/bootstrap/form_builder/map"
require "rug_builder/bootstrap/form_builder/multiple"
require "rug_builder/bootstrap/form_builder/picker"
require "rug_builder/bootstrap/form_builder/radio"
require "rug_builder/bootstrap/form_builder/rater"
require "rug_builder/bootstrap/form_builder/read_only"
require "rug_builder/bootstrap/form_builder/section"
require "rug_builder/bootstrap/form_builder/text_area"
require "rug_builder/bootstrap/form_builder/text_input"
require "rug_builder/bootstrap/form_builder/token_input"

module RugBuilder
#	module Bootstrap
		class FormBuilder < ActionView::Helpers::FormBuilder

			#def initialize(object_name, object, template, options)
			#	super(object_name, object, template, options)
			#end

		end
#	end
end
