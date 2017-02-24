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

# Railtie
require 'rug_record/railtie' if defined?(Rails)

# Importer
require "rug_record/importer"

module RugRecord

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
	# Enable config
	#
	mattr_accessor :enable_config
	@@enable_config = true

	#
	# Enable hierarchical ordering
	#
	# Use gem 'awesome_nested_set', '~> 3.0' if enabled
	#
	mattr_accessor :enable_hierarchical_ordering
	@@enable_hierarchical_ordering = false

	#
	# Enable json
	#
	mattr_accessor :enable_json
	@@enable_json = true

	#
	# Enable localization
	#
	mattr_accessor :enable_localization
	@@enable_localization = true

	#
	# Enable ordering
	#
	# Use gem 'acts_as_list' if enabled
	#
	mattr_accessor :enable_ordering
	@@enable_ordering = false

	#
	# Enable remote model
	#
	mattr_accessor :enable_remote_model
	@@enable_remote_model = true

	#
	# Enable sorting
	#
	mattr_accessor :enable_sorting
	@@enable_sorting = true

	#
	# Enable statistics
	#
	# Use gem 'groupdate' if enabled
	#
	mattr_accessor :enable_statistics
	@@enable_statistics = false

	#
	# Enable type address
	#
	mattr_accessor :enable_type_address
	@@enable_type_address = true

	#
	# Enable type array
	#
	mattr_accessor :enable_type_array
	@@enable_type_array = true

	#
	# Enable type croppable picture
	#
	# Use gem 'paperclip', '~> 4.2' if enabled
	#
	mattr_accessor :enable_type_croppable_picture
	@@enable_type_croppable_picture = false

	#
	# Enable type currency
	#
	mattr_accessor :enable_type_currency
	@@enable_type_currency = true

	#
	# Enable type datetime range
	#
	mattr_accessor :enable_type_datetime_range
	@@enable_type_datetime_range = true

	#
	# Enable type duration
	#
	mattr_accessor :enable_type_duration
	@@enable_type_duration = true

	#
	# Enable type enum
	#
	mattr_accessor :enable_type_enum
	@@enable_type_enum = true

	#
	# Enable type geolocation
	#
	mattr_accessor :enable_type_geolocation
	@@enable_type_geolocation = true

	#
	# Enable type geopolygon
	#
	# Use gems
	#  - gem 'geometry', '~> 6.5'
	#  - gem 'clipper', '~> 2.9'
	# if enabled
	#
	mattr_accessor :enable_type_geopolygon
	@@enable_type_geopolygon = false

	#
	# Enable type georectangle
	#
	mattr_accessor :enable_type_georectangle
	@@enable_type_georectangle = true

	#
	# Enable type name
	#
	mattr_accessor :enable_type_name
	@@enable_type_name = true

	#
	# Enable type range
	#
	mattr_accessor :enable_type_range
	@@enable_type_range = true

	#
	# Enable type state
	#
	mattr_accessor :enable_type_state
	@@enable_type_state = true

	#
	# Enable type store
	#
	# Add 'hstore' Postgres extension if enabled
	#
	mattr_accessor :enable_type_store
	@@enable_type_store = false

end