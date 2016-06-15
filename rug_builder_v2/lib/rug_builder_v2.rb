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

# Common parts
require "rug_builder/columns"
require "rug_builder/formatter"

# Railtie
require 'rug_builder/railtie' if defined?(Rails)

module RugBuilder

	# *************************************************************************
	# Configuration
	# *************************************************************************

	#
	# Default way to setup module
	#
	def self.setup
		yield self
	end

	# *************************************************************************
	# Config options
	# *************************************************************************

	#
	# Frontend framework
	#
	mattr_accessor :frontend_framework
	@@frontend_framework = "bootstrap"

end