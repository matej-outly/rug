# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Common importer parent
# *
# * Author: Matěj Outlý
# * Date  : 12. 11. 2016
# *
# *****************************************************************************

module RugRecord
	class Importer

		# *************************************************************************
		# Settings
		# *************************************************************************

		def self.set_driver(new_driver)
			@driver = new_driver
		end
		def self.get_driver
			(@driver ? @driver : :pgsql)
		end

		def self.set_host(new_host)
			@host = new_host
		end
		def self.get_host
			(@host ? @host : "localhost")
		end

		def self.set_username(new_username)
			@username = new_username
		end
		def self.get_username
			(@username ? @username : "")
		end

		def self.set_database(new_database)
			@database = new_database
		end
		def self.get_database
			(@database ? @database : "")
		end

		def self.set_password(new_password)
			@password = new_password
		end
		def self.get_password
			(@password ? @password : "")
		end

		def self.set_logging(new_logging)
			@logging = new_logging
		end
		def self.get_logging
			(@logging ? @logging : :simple)
		end

		def self.set_exceptions(new_exceptions)
			@exceptions = new_exceptions
		end
		def self.get_exceptions
			(@exceptions ? @exceptions : :supress)
		end

		# *************************************************************************
		# Definition
		# *************************************************************************

		def self.def_import_query(key, query)
			self.import_defs[key] = {} if self.import_defs[key].nil?
			self.import_defs[key][:query] = query
		end

		def self.def_import_row_block(key, &row_block)
			self.import_defs[key] = {} if self.import_defs[key].nil?
			self.import_defs[key][:row_block] = row_block
		end

		def self.disable_import(key)
			self.import_defs[key] = {} if self.import_defs[key].nil?
			self.import_defs[key][:disabled] = true
		end

		def self.import_defs
			if @import_defs.nil?
				@import_defs = {}
			end
			return @import_defs
		end

		# *************************************************************************
		# Process
		# *************************************************************************

		def self.import(options = {})
			begin
				self.import_defs.each do |import_key, import_def|
					self.do_import(import_key, import_def) if import_def[:disabled] != true
				end
			rescue Exception => e 
				if self.get_exceptions == :raise || options[:exceptions] == :raise
					raise e
				else
					return false
				end
			end
			return true
		end
	 
	protected

		# *************************************************************************
		# Process
		# *************************************************************************

		def self.do_import(import_key, import_def)
			return false if import_def[:query].nil?

			# Make remote database query
			data = self.exec(import_def[:query].to_s)
			
			# Establish connection to local database (not necessary, local connection not lost)
			# ...

			# Deactivate standard logging
			self.deactivate_logging
				
			# Progres logging
			self.init_progress(data.count, import_key)

			# For each found studentprop
			data.each_slice(50) do |slice|
				ActiveRecord::Base.transaction do
					slice.each do |row_data|

						# Call block
						import_def[:row_block].call(row_data) if import_def[:row_block]

						# Progress logging
						self.increment_progress

					end
				end
			end

			# Progress logging
			self.finish_progress

			# Activate standard logging
			self.activate_logging

			return true
		end

		# *************************************************************************
		# Connection
		# *************************************************************************

		#
		# Disconnect from local database and get established connection to classification portal
		#
		def self.connect
			if @connection.nil?
				if self.get_driver == :pgsql
					@connection = PG::Connection.new(
						host: self.get_host, 
						dbname: self.get_database, 
						user: self.get_username, 
						password: self.get_password
					)
				elsif self.get_driver == :mysql
					@connection = Mysql2::Client.new(
						host: self.get_host, 
						database: self.get_database, 
						username: self.get_username, 
						password: self.get_password
					)
				end
			end
			return @connection
		end

		#
		# Disconnect from classification portal and connect to local database again
		#
		def self.disconnect
			if !@connection.nil?
				if self.get_driver == :pgsql
					@connection.finish
				elsif self.get_driver == :mysql
					@connection.close
				end
			end
			@connection = nil
			return nil
		end

		#
		# Execute a query to remote database
		#
		def self.exec(query)
			if self.get_driver == :pgsql
				result = self.connect.exec(query)
				self.disconnect
			elsif self.get_driver == :mysql
				result = self.connect.query(query)
				self.disconnect
			end
			return result
		end
		
		# *************************************************************************
		# Logging
		# *************************************************************************
		
		def self.deactivate_logging
			if self.get_logging == :simple
				@deactivated_logger = ActiveRecord::Base.logger
				ActiveRecord::Base.logger = nil
			end
		end

		def self.activate_logging
			if self.get_logging == :simple
				ActiveRecord::Base.logger = @deactivated_logger
				@deactivated_logger = nil
			end
		end

		def self.deactivated_logger
			@deactivated_logger
		end

		# *************************************************************************
		# Progress
		# *************************************************************************

		def self.init_progress(count, label)
			@progress_label = label.to_s
			@progress_count = count
			@progress_current = 0
			if self.deactivated_logger
				self.deactivated_logger.info("Progress #{@progress_label}: start")
			end
		end

		def self.increment_progress
			@progress_current += 1
			if self.deactivated_logger
				self.deactivated_logger.info("Progress #{@progress_label}: #{@progress_current}/#{@progress_count}")
			end
		end

		def self.finish_progress
			@progress_current = @progress_count
			if self.deactivated_logger
				self.deactivated_logger.info("Progress #{@progress_label}: stop")
			end
		end

	end
end