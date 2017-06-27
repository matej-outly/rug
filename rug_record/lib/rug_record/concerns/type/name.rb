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
							value = value.symbolize_keys.select { |key, value| [:title, :firstname, :lastname, :title_after].include?(key) } if !value.nil?
							
							# Store
							if value.blank?
								self.send("#{column.to_s}_title=", nil) if options[:title] == true
								self.send("#{column.to_s}_firstname=", nil)
								self.send("#{column.to_s}_lastname=", nil)
								self.send("#{column.to_s}_title_after=", nil) if options[:title_after] == true
							else
								self.send("#{column.to_s}_title=", value[:title]) if options[:title] == true
								self.send("#{column.to_s}_firstname=", value[:firstname])
								self.send("#{column.to_s}_lastname=", value[:lastname])
								self.send("#{column.to_s}_title_after=", value[:title_after]) if options[:title_after] == true
							end
						end

						# Get method
						define_method(new_column.to_sym) do
							column = new_column
							options = new_options
							value_title = self.send("#{column.to_s}_title") if options[:title] == true
							value_firstname = self.send("#{column.to_s}_firstname")
							value_lastname = self.send("#{column.to_s}_lastname")
							value_title_after = self.send("#{column.to_s}_title_after") if options[:title_after] == true
							if value_firstname.blank? && value_lastname.blank?
								return nil
							else
								result = {}
								result[:title] = value_title if options[:title] == true
								result[:firstname] = value_firstname
								result[:lastname] = value_lastname
								result[:title_after] = value_title_after if options[:title_after] == true
								return result
							end
						end

						# Get method
						define_method("#{new_column}_formatted".to_sym) do
							column = new_column
							return RugBuilder::Formatter.name(self.send(column))
						end

						# Set method
						define_method("#{new_column}_formatted=".to_sym) do |value|
							column = new_column
							parsed_value = self.class.parse_name(value.to_s)
							self.send("#{column}=".to_sym, {
								title: parsed_value[0],
								firstname: parsed_value[1],
								lastname: parsed_value[2],
								title_after: parsed_value[3]
							})
						end

						# Attribute for filter
						attr_accessor "#{new_column}_for_filter".to_sym

					end

					#
					# Parse name
					#
					def parse_name(name)
						title = nil
						firstname = nil
						lastname = nil
						title_after = nil
						name_parts = name.to_s.split(" ")
						if name_parts.length == 0 # Nothing to do
						elsif name_parts.length == 1 # Only one part => it's firstname
							firstname = name_parts[0]
						elsif name_parts.length == 2 # Standard case
							firstname = name_parts[0]
							lastname = name_parts[1]
						elsif name_parts.length >= 3
							if name_parts[0].end_with?(".")
								title = name_parts.shift
							end
							lastname = name_parts.pop
							firstname = name_parts.join(" ")
						end
						return [title, firstname, lastname, title_after]	
					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Name)
