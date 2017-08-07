# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * 
# *
# * Author: Matěj Outlý
# * Date  : 21. 8. 2015
# *
# *****************************************************************************

module RugSupport
	class PathResolver

		def initialize(template)
			@template = template
		end

		#
		# Resolve if path is defined as lambda or as a string or symbol and convert it to valid application URL
		#
		def resolve(path, *args)
			if path.is_a?(Proc)
				return path.call(*args)
			elsif path.is_a?(String) || path.is_a?(Symbol)
				callee = @template
				path.to_s.split(".").slice(0..-2).each { |path_path| callee = callee.send(path_path.to_sym) }
				path_method = path.to_s.split(".").slice(-1).to_sym
				return callee.send(path_method, *args)
			else
				return path
			end
		end

	end
end
