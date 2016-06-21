# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Name definition
# *
# * Author: Matěj Outlý
# * Date  : 30. 11. 2015
# *
# *****************************************************************************

require "active_record"

module RugRecord
	module Concerns
		module Type
			module Name extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new address column
					#
					def name_column(new_column, new_options = {})
					
						# Set method
						define_method((new_column.to_s + "=").to_sym) do |value|
							column = new_column
							options = new_options
							
							# Convert string to Hash 
							if value.is_a? ::String
								if !value.blank?
									value = JSON.parse(value)
								else
									value = nil
								end
							end

							# Check type
							if !value.nil? && !value.is_a?(Hash)
								raise "Wrong value format, expecting Hash or nil."
							end

							# Filter
							value = value.symbolize_keys.select { |key, value| [:title, :firstname, :lastname].include?(key) } if !value.nil?
							
							# Store
							if value.blank?
								self.send("#{column.to_s}_title=", nil) if options[:title] == true
								self.send("#{column.to_s}_firstname=", nil)
								self.send("#{column.to_s}_lastname=", nil)
							else
								self.send("#{column.to_s}_title=", value[:title]) if options[:title] == true
								self.send("#{column.to_s}_firstname=", value[:firstname])
								self.send("#{column.to_s}_lastname=", value[:lastname])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							options = new_options
							value_title = self.send("#{column.to_s}_title") if options[:title] == true
							value_firstname = self.send("#{column.to_s}_firstname")
							value_lastname = self.send("#{column.to_s}_lastname")
							if value_firstname.blank? && value_lastname.blank?
								return nil
							else
								result = {}
								result[:title] = value_title if options[:title] == true
								result[:firstname] = value_firstname
								result[:lastname] = value_lastname
								return result
							end
						end

						# Get method
						define_method("#{new_column}_formatted".to_sym) do
							column = new_column
							return RugBuilder::Formatter.name(self.send(column))
						end

						# Attribute for filter
						attr_accessor "#{new_column}_for_filter".to_sym

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Name)
