# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug support
# *
# * Author: Matěj Outlý
# * Date  : 10. 11. 2014
# *
# *****************************************************************************

# Active support
require "active_support"
require "active_support/core_ext"

# Core extensions
require "rug_support/util/array"
require "rug_support/util/date"
require "rug_support/util/datetime"
require "rug_support/util/hash"
require "rug_support/util/object"
require "rug_support/util/string"
require "rug_support/util/time"
require "rug_support/util/uri"

# Rails extension
require "rug_support/routes_reloader" if defined?(Rails)
require "rug_support/path_resolver"

module RugSupport
end
