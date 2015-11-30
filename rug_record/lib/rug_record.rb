# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug record
# *
# * Author: Matěj Outlý
# * Date  : 22. 5. 2014
# *
# *****************************************************************************

# Basic
require "rug_record/config"
require "rug_record/cropper"

# Type extensions (concerns)
require "rug_record/concerns/type/address"
require "rug_record/concerns/type/array"
require "rug_record/concerns/type/enum"
require "rug_record/concerns/type/croppable_picture"
require "rug_record/concerns/type/geolocation"
require "rug_record/concerns/type/georectangle"
require "rug_record/concerns/type/geopolygon"
require "rug_record/concerns/type/name"
require "rug_record/concerns/type/range"

# Concerns
require "rug_record/concerns/config"
require "rug_record/concerns/hierarchical_ordering"
#require "rug_record/concerns/identification"
require "rug_record/concerns/json"
require "rug_record/concerns/localization"
require "rug_record/concerns/ordering"
require "rug_record/concerns/remote_model"
require "rug_record/concerns/sorting"

