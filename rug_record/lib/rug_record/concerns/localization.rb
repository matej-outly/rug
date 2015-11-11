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
					
					# Getter
					define_method(new_column.to_sym) do
						column = new_column
						read_column = (column.to_s + "_" + language.to_s).to_sym
						return self.send(read_column)
					end

					# Setter
					define_method((new_column.to_s + "=").to_sym) do |value|
						column = new_column
						written_column = (column.to_s + "_" + language.to_s + "=").to_sym
						return self.send(written_column, value)
					end

				end

				#
				# Get class-scope language
				#
				def language
					return I18n.locale
				end

			end

			#
			# Set instance-scope language
			#
			def language=(instance_language)
				@instance_language = instance_language
			end

			#
			# Get language
			#
			def language
				if @instance_language.nil?
					if self.class.language.nil?
						raise "Language must be defined."
					else
						return self.class.language
					end
				else
					return @instance_language
				end
			end
			
			#
			# Is model localized?
			#
			def localized?
				return true
			end
			
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Localization)
