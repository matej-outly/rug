# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * URI utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 20. 7. 2015
# *
# *****************************************************************************

class URI::Generic

	def params
		@params = query_to_params(self.query) if @params.nil?
		return @params
	end

	def params=(new_params)
		@params = new_params
		self.query = params_to_query(@params)
	end

private

	def query_to_params(query)
		result = {}
		if query
			query_parts = query.split("&")
			query_parts.each do |query_part|
				param_parts = query_part.split("=")
				result[param_parts[0].to_sym] = param_parts[1].to_s
			end
		end
		return result
	end

	def params_to_query(params)
		query_parts = []
		params.each do |key, value|
			query_parts << "#{key.to_s}=#{value.to_s}"
		end
		return query_parts.join("&")
	end

end