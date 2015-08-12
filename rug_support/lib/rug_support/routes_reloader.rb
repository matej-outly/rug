# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Rails routes reloader extension adding ability to load engine specific 
# * route files.
# *
# * Author: Matěj Outlý
# * Date  : 10. 11. 2014
# *
# *****************************************************************************

module Rails
	class Application
		class RoutesReloader

			def load_engines
				engines = ::Rails::Engine.subclasses.map(&:instance)
				engines.each do |engine|
					if engine.respond_to?(:reload_routes)
						engine.reload_routes
					end
				end
			end

			def reload!
				clear!
				load_paths
				load_engines # Extension
				finalize!
			ensure
				revert
			end

		end
	end
end