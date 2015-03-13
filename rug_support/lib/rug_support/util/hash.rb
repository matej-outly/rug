# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Hash utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 15. 5. 2014
# *
# *****************************************************************************

class Object

	#
	# Deep symbolize keys in hash
	#
	# See http://stackoverflow.com/questions/800122
	#
	def rug_deep_symbolize_keys
		if self.is_a? Hash
			return self.inject({}) { |memo,(k,v)| memo[k.to_sym] =  v.rug_deep_symbolize_keys; memo } 
		elsif self.is_a? Array
			return self.inject([]) { |memo,v    | memo           << v.rug_deep_symbolize_keys; memo } 
		else
			return self
		end
	end

end

class Hash

	#
	# Symbolize keys in hash
	#
	def rug_symbolize_keys
		return self.inject({}) { |memo,(k,v)| memo[k.to_sym] =  v; memo } 
	end

	#
	# Deep merging of hashes
	#
	# By Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
	#
	def rug_deep_merge(other_hash)
		merger = proc {|k, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
		self.merge!(other_hash, &merger)
	end

	#
	# Deep merging of hashes
	#
	def rug_merge(other_hash)
		self.merge!(other_hash)
	end

end