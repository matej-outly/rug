# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Currency definition
# *
# * Author: Matěj Outlý
# * Date  : 2. 12. 2016
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Currency extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new enum column
					#
					def currency_column(new_column, options = {})
					
						# All method
						define_singleton_method(("available_" + new_column.to_s.pluralize).to_sym) do
							result = []
							["CZK", "EUR"].each do |currency|
								locale = self.send((new_column.to_s + "_to_locale").to_sym, currency)
								result << currency if I18n.available_locales.include?(locale)
							end
							return result
						end

						# Convert method
						define_singleton_method((new_column.to_s + "_to_locale").to_sym) do |value|
							return case value
								when "CZK" then :cs
								when "EUR" then :en
								else nil
							end
						end

						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column
							
							# Retype
							value = value.to_s

							# Check available currencies
							if !self.class.send(("available_" + new_column.to_s.pluralize).to_sym).include?(value)
								value = nil
							end

							# Save
							write_attribute(column.to_sym, value)
						end

						# Get as locale method
						define_method((new_column.to_s + "_as_locale").to_sym) do
							column = new_column
							return self.class.send((new_column.to_s + "_to_locale").to_sym, read_attribute(column.to_sym))
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Currency)