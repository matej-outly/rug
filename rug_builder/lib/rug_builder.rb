# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug builder
# *
# * Author: Matěj Outlý
# * Date  : 27. 4. 2015
# *
# *****************************************************************************

# Builders
require "rug_builder/form_builder"
require "rug_builder/table_builder"
require "rug_builder/menu_builder"

# Railtie
require 'rug_builder/railtie' if defined?(Rails)
