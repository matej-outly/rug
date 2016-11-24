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
		# Constructor
		# *************************************************************************

		def initialize(settings = {})
			
		end

		# *************************************************************************
		# Settings
		# *************************************************************************

		def self.default_settings
			{
				# Driver distinguishing
				driver: nil,
				
				# SQL settings
				host: "localhost",
				username: "",
				password: "",
				database: "",
				encoding: "utf8",
				
				# Behaviour settings
				logging: :simple,
				exceptions: :supress,
			}
		end

		def self.settings
			@settings = self.default_settings.dup if @settings.nil?
			return @settings
		end

		def settings
			@settings = self.class.settings.dup if @settings.nil?
			return @settings
		end

		default_settings.keys.each do |new_setting|
			
			define_singleton_method("validate_#{new_setting.to_s}".to_sym) do |value|
				return true
			end

			define_singleton_method("set_#{new_setting.to_s}".to_sym) do |value|
				setting = new_setting
				raise "Invalid #{new_setting.to_s} '#{value.to_s}'." if !self.send("validate_#{new_setting.to_s}".to_sym, value)
				self.settings[setting] = value
			end

			define_singleton_method("get_#{new_setting.to_s}".to_sym) do
				setting = new_setting
				return self.settings[setting]
			end

			define_method("set_#{new_setting.to_s}".to_sym) do |value|
				setting = new_setting
				raise "Invalid #{new_setting.to_s} '#{value.to_s}'." if !self.slass.send("validate_#{new_setting.to_s}".to_sym, value)
				self.settings[setting] = value
			end

			define_method("get_#{new_setting.to_s}".to_sym) do
				setting = new_setting
				return self.settings[setting]
			end

		end

		def self.validate_driver(value)
			return [:pgsql, :mysql, :xml, :xml_gzip, :xml_folder_zip].include?(value.to_sym)
		end

		def self.validate_logging(value)
			return [:simple, :natural].include?(value.to_sym)
		end

		def self.validate_exceptions(value)
			return [:supress, :raise].include?(value.to_sym)
		end

		# *************************************************************************
		# Imports
		# *************************************************************************

		def self.imports
			@imports = {} if @imports.nil?
			return @imports
		end

		def imports
			return self.class.imports
		end

		def self.def_import_option(key, option_name, value)
			self.imports[key] = {} if self.imports[key].nil?
			self.imports[key][option_name.to_sym] = value
		end

		def self.def_import_custom_block(key, &custom_block)
			self.def_import_option(key, :custom_block, custom_block)
		end

		def self.def_import_query(key, query)
			self.def_import_option(key, :query, query)
		end

		def self.def_import_url(key, url)
			self.def_import_option(key, :url, url)
		end

		def self.def_import_block(key, &block)
			self.def_import_option(key, :block, block)
		end

		def self.disable_import(key)
			self.def_import_option(key, :disabled, true)
		end

		def self.enable_import(key)
			self.def_import_option(key, :disabled, false)
		end

		# *************************************************************************
		# Process
		# *************************************************************************

		def import(options = {})
			begin
				
				# Deactivate standard logging
				deactivate_logging

				# Before callback
				before_imports

				# Around callback
				around_imports do 

					# Perform imports
					self.imports.each do |key, import_options|
						import_options = import_options.merge(options)
						if import_options[:disabled] != true
							if import_options[:custom_block] 
								instance_exec(key, import_options, &import_options[:custom_block])
							elsif [:pgsql, :mysql].include?(get_driver)
								import_sql(key, import_options) 
							elsif [:xml, :xml_gzip, :xml_folder_zip].include?(get_driver)
								import_xml(key, import_options) 
							end
						end
					end

				end

				# After callback
				after_imports

				# Activate standard logging
				activate_logging

			rescue Exception => e 

				# Activate standard logging
				activate_logging

				# Handle exception
				if get_exceptions == :raise || options[:exceptions] == :raise
					raise e
				else
					return false
				end

			end
			return true
		end

		def i(options)
			return self.import(options)
		end

		def self.import(options = {})
			instance = self.new
			return instance.import(options)
		end

		def self.i(options = {})
			return self.import(options)
		end

		def self.queue
			# TODO
		end

		def queue
			return self.class.queue
		end
	 
	protected

		# *************************************************************************
		# Process
		# *************************************************************************

		def import_sql(key, options)
			return false if options[:query].nil?

			# Make remote database query
			data = sql_exec(options[:query].to_s)
			
			# Establish connection to local database (not necessary, local connection not lost)
			# ...

			# Progres logging
			init_progress(data.count, key)

			# For each found studentprop
			data.each_slice(50) do |slice|
				ActiveRecord::Base.transaction do
					slice.each do |data|

						# Call block
						instance_exec(data, options, &options[:block]) if options[:block]

						# Progress logging
						increment_progress

					end
				end
			end

			# Progress logging
			finish_progress

			return true
		end

		def import_xml(key, options)
			return false if options[:url].blank?

			# Progres logging
			init_progress(nil, key)

			# Load main document
			instance_exec(options, &options[:block]) if options[:block]

			# Progress logging
			finish_progress

			return true
		end

		# *************************************************************************
		# SQL
		# *************************************************************************

		#
		# Disconnect from local database and get established connection to classification portal
		#
		def sql_connect
			if @connection.nil?
				if get_driver == :pgsql
					require "pg"
					@connection = PG::Connection.new(
						host: get_host, 
						dbname: get_database, 
						user: get_username, 
						password: get_password
					)
				elsif get_driver == :mysql
					require "mysql2"
					@connection = Mysql2::Client.new(
						host: get_host, 
						database: get_database, 
						username: get_username, 
						password: get_password,
						encoding: get_encoding
					)
				end
			end
			return @connection
		end

		#
		# Disconnect from classification portal and connect to local database again
		#
		def sql_disconnect
			if !@connection.nil?
				if get_driver == :pgsql
					@connection.finish
				elsif get_driver == :mysql
					@connection.close
				end
			end
			@connection = nil
			return nil
		end

		#
		# Execute a query to remote database
		#
		def sql_exec(query)
			disconnect_after_exec = (@connection.nil?)
			if get_driver == :pgsql
				result = sql_connect.exec(query)
			elsif get_driver == :mysql
				result = sql_connect.query(query)
			end
			sql_disconnect if disconnect_after_exec
			return result
		end

		# *************************************************************************
		# Common URL
		# *************************************************************************
		
		def load_from_url(url)
			url = URI.escape(url)
			if url.starts_with?("ftp://")
				require "net/ftp"
				splitted_url = url[6..-1].split("/")
				hostname = splitted_url.shift
				filename = splitted_url.join("/")
				ftp = Net::FTP.new
				ftp.connect(hostname, 21)
				if !get_username.blank? && !get_password.blank?
					ftp.login(get_username, get_password)
				end
				ftp.passive = true
				result = ftp.getbinaryfile(filename, nil)
				ftp.close
			else
				require "rest-client"
				rest_client_options = {}
				rest_client_options[:url] = URI.escape(url)
				rest_client_options[:method] = :get
				if !get_username.blank? && !get_password.blank?
					rest_client_options[:user] = get_username
					rest_client_options[:password] = get_password
				end
				result = RestClient::Request.execute(rest_client_options)
			end
			return result
		end

		# *************************************************************************
		# XML
		# *************************************************************************

		def xml_load(url)
			if ![:xml, :xml_gzip, :xml_folder_zip].include?(get_driver)
				raise "Can't call xml_load for driver '#{get_driver}'."
			end

			# Require
			require "nokogiri"
			
			# Get raw data from remote server
			response = load_from_url(url)
			
			# Parse data into nokogiri document
			if get_driver == :xml
				yield Nokogiri::XML(response)
			
			elsif get_driver == :xml_gzip
				require "zlib" 
				
				# Create temp file
				tmp_file = Tempfile.new("import")
				tmp_file.binmode
				tmp_file.write(response)
				
				# Extract gzip
				yield Nokogiri::XML(Zlib::GzipReader.open(tmp_file.path).read)
				
				# Delte tempfile
				tmp_file.close
				tmp_file.unlink 

			elsif get_driver == :xml_folder_zip
				require "zip"

				# Create temp file
				tmp_file = Tempfile.new("import")
				tmp_file.binmode
				tmp_file.write(response)
				
				# Extract zip
				Zip::File.open(tmp_file.path) do |zip_file|
					zip_file.each do |entry|
						if entry.name.ends_with?(".xml")
							yield Nokogiri::XML(entry.get_input_stream.read)
						end
					end
				end

				# Delte tempfile
				tmp_file.close
				tmp_file.unlink 
			end
			
			return true
		end

		def xml_inner_text(element)
			if element
				return element.inner_text.to_s
			else
				return ""
			end
		end

		def xml_attr(element, attribute)
			if element && attribute
				return element[attribute].to_s
			else
				return ""
			end
		end

		# *************************************************************************
		# Logging
		# *************************************************************************
		
		def deactivate_logging
			if get_logging == :simple
				@deactivated_logger = ActiveRecord::Base.logger
				ActiveRecord::Base.logger = nil
			end
		end

		def activate_logging
			if get_logging == :simple
				ActiveRecord::Base.logger = @deactivated_logger
				@deactivated_logger = nil
			end
		end

		def deactivated_logger
			@deactivated_logger
		end

		# *************************************************************************
		# Progress
		# *************************************************************************

		def init_progress(count, label)
			@progress_label = label.to_s
			@progress_count = count
			@progress_current = 0
			if deactivated_logger
				deactivated_logger.info("Progress #{@progress_label}: start")
			end
		end

		def increment_progress
			@progress_current += 1
			if deactivated_logger
				deactivated_logger.info("Progress #{@progress_label}: #{@progress_current}/#{@progress_count}")
			end
		end

		def finish_progress
			@progress_current = @progress_count
			if deactivated_logger
				deactivated_logger.info("Progress #{@progress_label}: stop")
			end
		end

		def tick_progress
			@progress_current += 1
			if deactivated_logger
				deactivated_logger.info("Progress #{@progress_label}: tick #{@progress_current}")
			end
		end

		# *************************************************************************
		# Callbacks
		# *************************************************************************

		#
		# To be overriden
		#
		def before_imports
		end

		#
		# To be overriden
		#
		def after_imports
		end

		#
		# To be overriden
		#
		def around_imports
			yield
		end

	end
end