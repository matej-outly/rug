# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Configuration object of controller
# *
# * Author: Matěj Outlý
# * Date  : 20. 7. 2015
# *
# *****************************************************************************

require "ostruct"
require "yaml"

module RugController
	class ControllerConfig < OpenStruct

		#
		# Name suffix of file containing configuration
		#
		CONFIG_SUFFIX = ".yml"

		#
		# Constructor
		#
		def initialize(controller_class)

			# Parent
			super(nil)

			# Basic
			@controller_type = controller_class.to_s
			
			# Path to this controller
			controller_path = @controller_type.to_snake

			# Preset
			@config_filenames = []

			# All load paths in reverse priority order
			load_paths.reverse_each do |load_path|

				# Common
				config_common_filename = load_path + "/" + controller_path + CONFIG_SUFFIX
				if File.exists?(config_common_filename)
					@config_filenames << config_common_filename
					load(config_common_filename)
				end

			end

		end

		#
		# Merge current options with new options
		#
		def merge(options)
			if options.is_a? Hash

				# Convert keys to symbols
				options = options.rug_deep_symbolize_keys

				# Merge with config options loaded earlier (with lower priority)
				@table.rug_merge(options)

			end
		end

	protected
			
		#
		# Paths where to search for config files
		#
		def load_paths
			result = []
			$LOAD_PATH.each do |load_path|
				if load_path.to_s.end_with?("controllers")
					result << load_path.to_s.sub(/\/app\//, "/config/")
				end
			end
			return result
		end

		#
		# Load single configuration file
		#
		def load(filename)

			# Parse config file
			new_options = YAML::load_file(filename)

			# Merge with current options
			merge(new_options)

		end

	end
end