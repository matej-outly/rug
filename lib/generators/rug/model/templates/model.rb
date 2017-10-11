# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * <%= model_name.singularize.gsub("_", " ").capitalize %>
# *
# * Author: 
# * Date  : <%= Date.today.strftime("%-d. %-m. %Y") %>
# *
# *****************************************************************************

class <%= model_path.to_camel.singularize %> < ActiveRecord::Base

	# *************************************************************************
	# Structure
	# *************************************************************************

	# *************************************************************************
	# Validators
	# *************************************************************************
	
	# *************************************************************************
	# Scopes
	# *************************************************************************

	def self.filter(params)
		
		# Preset
		result = all

		# Name
		if !params[:name].blank?
			result = result.where("lower(unaccent(name)) LIKE ('%' || lower(unaccent(trim(?))) || '%')", params[:name].to_s)
		end

		result
	end

	def self.search(query)
		if query.blank?
			all
		else
			where("
				(lower(unaccent(name)) LIKE ('%' || lower(unaccent(trim(:query))) || '%'))
			", query: query.to_s)
		end
	end

	# *************************************************************************
	# Columns
	# *************************************************************************
	
	def self.permitted_columns
		[
			:name
		]
	end

	def self.filter_columns
		[
			:name
		]
	end

end
