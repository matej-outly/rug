
module RugSupport
	module Util
		class Path

			#
			# Resolve if path is defined as lambda or as constant and convert it to 
			#
			def self.resolve(path, object)
				if path.is_a?(Proc)
					if object.nil?
						return path.call
					else
						return path.call(object)
					end
				else
					callee = @template
					path.to_s.split(".").slice(0..-2).each { |path_path| callee = callee.send(path_path.to_sym) }
					path_method = path.to_s.split(".").slice(-1).to_sym
					if object.nil?
						return callee.send(path_method)
					else
						return callee.send(path_method, object)
					end
				end
			end

		end
	end
end
