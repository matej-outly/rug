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
	def deep_symbolize_keys
		if self.is_a? Hash
			return self.inject({}) { |memo,(k,v)| memo[k.to_sym] =  v.deep_symbolize_keys; memo } 
		elsif self.is_a? Array
			return self.inject([]) { |memo,v    | memo           << v.deep_symbolize_keys; memo } 
		else
			return self
		end
	end

	#
	# Deep integerize keys
	#
	def deep_integerize_keys
		if self.is_a? Hash
			return self.inject({}) { |memo,(k,v)| memo[k.to_i] =  v.deep_integerize_keys; memo } 
		elsif self.is_a? Array
			return self.inject([]) { |memo,v    | memo         << v.deep_integerize_keys; memo } 
		else
			return self
		end
	end

	#
	# Deep snake case keys
	#
	def deep_snake_keys
		if self.is_a? Hash
			return self.inject({}) { |memo,(k,v)| memo[k.to_s.to_snake] =  v.deep_snake_keys; memo } 
		elsif self.is_a? Array
			return self.inject([]) { |memo,v    | memo                  << v.deep_snake_keys; memo } 
		else
			return self
		end
	end

	#
	# Deep calel case keys
	#
	def deep_camel_keys
		if self.is_a? Hash
			return self.inject({}) { |memo,(k,v)| memo[k.to_s.to_camel] =  v.deep_camel_keys; memo } 
		elsif self.is_a? Array
			return self.inject([]) { |memo,v    | memo                  << v.deep_camel_keys; memo } 
		else
			return self
		end
	end

end

class Hash

	#
	# Convert all keys in hash into symbols
	#
	def symbolize_keys
		return self.inject({}) { |memo,(k,v)| memo[k.to_sym] = v; memo } 
	end

	#
	# Convert all keys in hash into integers
	#
	def integerize_keys
		return self.inject({}) { |memo,(k,v)| memo[k.to_i] = v; memo } 
	end

	#
	# Convert all keys in hash into snake case
	#
	def snake_keys
		return self.inject({}) { |memo,(k,v)| memo[k.to_s.to_snake] = v; memo } 
	end

	#
	# Convert all keys in hash into camel case
	#
	def camel_keys
		return self.inject({}) { |memo,(k,v)| memo[k.to_s.to_camel] = v; memo } 
	end

	#
	# Deep merging of hashes
	#
	# By Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
	#
	def deep_merge!(other_hash)
		merger = proc {|k, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
		self.merge!(other_hash, &merger)
	end

	#
	# Convert to object recursively
	#
	def to_o
		JSON.parse(self.to_json, object_class: OpenStruct)
	end

end