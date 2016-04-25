# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Railtie for dynamic concerns integration
# *
# * Author: Matěj Outlý
# * Date  : 21. 4. 2016
# *
# *****************************************************************************

puts "RECORD LOAD"

module RugRecord
	class Railtie < Rails::Railtie

		config.before_initialize do
			
			# There is no hook after initializers loading and before routes 
			# loading (RugRecord must be completely initialized for routes 
			# loading). Therefore we need to use this hook before initializers
			# are loaded and force a special rug_record.rb initializer to be 
			# included in advance (we expect that this initializer defines 
			# which RugRecord submodules should be loaded).
			config_path = Rails.root.to_s + "/config/initializers/rug_record.rb"
			if File.file?(config_path)
				require config_path
			end

			# Concerns
			require "rug_record/concerns/config" if RugRecord.enable_config
			require "rug_record/concerns/hierarchical_ordering"if RugRecord.enable_hierarchical_ordering
			require "rug_record/concerns/json"if RugRecord.enable_json
			require "rug_record/concerns/localization"if RugRecord.enable_localization
			require "rug_record/concerns/ordering"if RugRecord.enable_ordering
			require "rug_record/concerns/remote_model"if RugRecord.enable_remote_model
			require "rug_record/concerns/sorting"if RugRecord.enable_sorting

			# Type extensions (concerns)
			require "rug_record/concerns/type/address" if RugRecord.enable_type_address
			require "rug_record/concerns/type/array" if RugRecord.enable_type_array
			require "rug_record/concerns/type/enum" if RugRecord.enable_type_enum
			require "rug_record/concerns/type/croppable_picture" if RugRecord.enable_type_croppable_picture
			require "rug_record/concerns/type/duration" if RugRecord.enable_type_duration
			require "rug_record/concerns/type/geolocation" if RugRecord.enable_type_geolocation
			require "rug_record/concerns/type/georectangle" if RugRecord.enable_type_georectangle
			require "rug_record/concerns/type/geopolygon" if RugRecord.enable_type_geopolygon
			require "rug_record/concerns/type/name" if RugRecord.enable_type_name
			require "rug_record/concerns/type/range" if RugRecord.enable_type_range
			require "rug_record/concerns/type/state" if RugRecord.enable_type_state

		end

	end
end