# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rug formatter - range type
# *
# * Author: Matěj Outlý
# * Date  : 10. 4. 2015
# *
# *****************************************************************************

module RugBuilder
	class Formatter

		# *********************************************************************
		# Generic range
		# *********************************************************************
		
		def self.range(value, options = {})
			if !value.nil?
				value_min = value[:min]
				value_max = value[:max]
				if value_min.blank? && value_max.blank?
					return ""
				elsif value_min.blank?
					return value_max
				elsif value_max.blank?
					return value_min
				else
					return "#{value_min} - #{value_max}"
				end
			else
				return ""
			end
		end

		# *********************************************************************
		# Integer range
		# *********************************************************************
		
		def self.integer_range(value, options = {})
			if !value.nil?
				value_min = value[:min]
				value_max = value[:max]
				if value_min.blank? && value_max.blank?
					return ""
				elsif value_min.blank?
					return self.integer(value_max)
				elsif value_max.blank?
					return self.integer(value_min)
				else
					return "#{self.integer(value_min)} - #{self.integer(value_max)}"
				end
			else
				return ""
			end
		end

		# *********************************************************************
		# Float range
		# *********************************************************************
		
		def self.float_range(value, options = {})
			if !value.nil?
				value_min = value[:min]
				value_max = value[:max]
				if value_min.blank? && value_max.blank?
					return ""
				elsif value_min.blank?
					return self.float(value_max)
				elsif value_max.blank?
					return self.float(value_min)
				else
					return "#{self.float(value_min)} - #{self.float(value_max)}"
				end
			else
				return ""
			end
		end

		# *********************************************************************
		# Double range
		# *********************************************************************
		
		def self.double_range(value, options = {})
			if !value.nil?
				value_min = value[:min]
				value_max = value[:max]
				if value_min.blank? && value_max.blank?
					return ""
				elsif value_min.blank?
					return self.double(value_max)
				elsif value_max.blank?
					return self.double(value_min)
				else
					return "#{self.double(value_min)} - #{self.double(value_max)}"
				end
			else
				return ""
			end
		end

	end
end