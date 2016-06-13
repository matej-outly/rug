# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * View helper
# *
# * Author: Matěj Outlý
# * Date  : 13. 6. 2016
# *
# *****************************************************************************

module RugBuilder
	module Helpers
		module FormatHelper

			[:address, :string_array, :string, :text, :integer, :currency, :url, :date, :time, :datetime, :duration, :enum, :boolean, :state, :file, :picture, :geolocation, :georectangle, :geopolygon, :name, :range, :integer_range, :double_range, :belongs_to, :has_many].each do |new_type|
				define_method("rug_format_#{new_type}".to_sym) do |value, options = {}|
					type = new_type
					RugBuilder::Formatter.initialize(self)
					return RugBuilder::Formatter.method(type.to_sym).call(value, options)
				end
			end

		end
	end
end
