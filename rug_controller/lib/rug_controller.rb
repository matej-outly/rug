# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug controller
# *
# * Author: Matěj Outlý
# * Date  : 2. 6. 2015
# *
# *****************************************************************************

# Basic
require "rug_controller/component"
require "rug_controller/component_config"
require "rug_controller/broadcast"

# Concerns
require "rug_controller/concerns/controller_components"
require "rug_controller/concerns/controller_broadcast"
require "rug_controller/concerns/lifecycle"

# Railtie
require 'rug_controller/railtie' if defined?(Rails)