# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * ActiveRecord localization
# *
# * Author: Matěj Outlý
# * Date  : 21. 8. 2014
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Localization extend ActiveSupport::Concern

			module ClassMethods
				
				#
				# Add new localized column
				#
				def localized_column(new_column)
					
					# Column getter
					define_method(new_column.to_sym) do
						column = new_column
						read_column = (column.to_s + "_" + self.locale.to_s).to_sym
						return self.send(read_column)
					end

					# Column setter
					define_method((new_column.to_s + "=").to_sym) do |value|
						column = new_column
						written_column = (column.to_s + "_" + self.locale.to_s + "=").to_sym
						return self.send(written_column, value)
					end

					if true

						# Class locale getter
						define_singleton_method("locale") do 
							if !@class_locale.nil?
								return @class_locale
							else
								return I18n.locale
							end
						end

						# Class locale setter
						define_singleton_method("locale=") do |value| 
							@class_locale = value
						end

						# Instance locale getter
						define_method("locale") do
							if @instance_locale.nil?
								if self.class.locale.nil?
									raise "Locale must be defined."
								else
									return self.class.locale
								end
							else
								return @instance_locale
							end
						end

						# Instance locale getter
						define_method("locale=") do |value|
							@instance_locale = value
						end

					end

				end

			end
			
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Localization)
