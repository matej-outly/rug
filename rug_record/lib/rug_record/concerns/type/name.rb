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
								write_attribute("#{column.to_s}_title", nil) if options[:title] == true
								write_attribute("#{column.to_s}_firstname", nil)
								write_attribute("#{column.to_s}_lastname", nil)
							else
								write_attribute("#{column.to_s}_title", value[:title]) if options[:title] == true
								write_attribute("#{column.to_s}_firstname", value[:firstname])
								write_attribute("#{column.to_s}_lastname", value[:lastname])
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							options = new_options
							value_title = read_attribute("#{column.to_s}_title") if options[:title] == true
							value_firstname = read_attribute("#{column.to_s}_firstname")
							value_lastname = read_attribute("#{column.to_s}_lastname")
							if value_firstname.blank? && value_lastname.blank?
								return nil
							else
								result = {}
								result[:title] = value_title if options[:title] == true
								result[:firstname] = value_firstname
								result[:lastname] = value_lastname
								result[:formatted] = self.send((column.to_s + "_formatted").to_sym)
								return result
							end
						end

						# Get method
						define_method((new_column.to_s + "_formatted").to_sym) do
							column = new_column
							options = new_options
							value_title = read_attribute("#{column.to_s}_title") if options[:title] == true
							value_firstname = read_attribute("#{column.to_s}_firstname")
							value_lastname = read_attribute("#{column.to_s}_lastname")
							if value_firstname.blank? && value_lastname.blank?
								return nil
							else
								result = ""
								result += "#{value_title.to_s} " if options[:title] == true && !value_title.blank?
								result += "#{value_firstname.to_s} " if !value_firstname.blank?
								result += value_lastname.to_s
								return result
							end
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Name)
