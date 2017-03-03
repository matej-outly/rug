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

		def next_batch
			return @next_batch
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

				# Batch and limits
				batch_size: nil, 
				xml_size_limit: 200, # in MB
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
			return [

				# DB
				:pgsql, 
				:mysql, 

				# XML
				:xml, 
				:xml_gzip, 
				:xml_folder_zip,

				# TXT
				:txt, 
				:txt_gzip, 
				:txt_folder_zip

			].include?(value.to_sym)
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

					begin
						
						# Init subject
						init_subject
						
						# Perform imports
						self.imports.each do |key, import_options|
							import_options = import_options.merge(options)
							if import_options[:disabled] != true
								if import_options[:custom_block] 
									instance_exec(key, import_options, &import_options[:custom_block])
								elsif [:pgsql, :mysql].include?(get_driver)
									import_sql(key, import_options) 
								else
									import_common(key, import_options) 
								end
							end
						end

						# Finish subject
						finish_subject
					
					rescue Exception => e 

						# Finish subject with error
						finish_subject(true, e.message)

						raise e
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

		def self.i(options = {})
			return self.import(options)
		end

		def self.import(options = {})
			instance = self.new
			return instance.import(options)
		end

		def self.import_and_enqueue(options = {})
			options = options.symbolize_keys # Repair options probably passed from previous QC job

			instance = self.new
			result = instance.import(options)

			# Finalize
			if instance.next_batch == true

				# Enqueue another batch
				QC.enqueue("#{self.to_s}.import_and_enqueue", options)
				return false
			
			else

				# Enqueue callback
				if options[:enqueue_callback]
					QC.enqueue(options[:enqueue_callback])
				end

				return true
			end
		end

		def import_and_enqueue(options = {})
			return self.class.import_and_enqueue(options)
		end

		def self.enqueue
			QC.enqueue("#{self.to_s}.import_and_enqueue")
		end

		def enqueue
			return self.class.enqueue
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

		def import_common(key, options)
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

			# FTP
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
			
			# Local file
			elsif url.starts_with?("file://")
				path = url[6..-1]
				result = File.read(path)
			
			# Standard URL
			else
				require "rest-client"
				rest_client_options = {}
				rest_client_options[:url] = url
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

		def xml_parse(data, options = {})

			# Normalize options
			options[:split_by_elements] = {options[:split_by_element].to_s => :parse} if !options[:split_by_element].nil?

			if !options[:split_by_elements].nil?
				element_names = options[:split_by_elements].keys

				# Prepare control structures
				context = {}

				Nokogiri::XML::Reader(data).each do |node|
					
					# Something interesting found
					if element_names.include?(node.name) && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
						
						# Last element found => parse it and yield with context
						if node.name == element_names.last
							attribute = options[:split_by_elements][node.name]
							if attribute === :parse
								if (node.outer_xml.length / 1048576) <= get_xml_size_limit # Size check (big XML data cannot be parsed to DOM)
									context[node.name] = Nokogiri::XML(node.outer_xml).first_element_child
								else
									raise "XML data too large."
								end
							else
								context[node.name] = node.attribute(attribute)
							end

							# Params for yield
							yield_params = []
							element_names.each do |element|
								yield_params << context[element]
							end
							
							# Yield
							if yield_params.length == 1
								yield yield_params.first
							else
								yield yield_params
							end

						# Do not parse, just save context
						else
							attribute = options[:split_by_elements][node.name]
							if attribute === :parse
								raise "Cannot parse context element, please specify single atrribute to retrieve."
							else
								context[node.name] = node.attribute(attribute)
							end
						end

					end

				end
			else
				if (data.length / 1048576) <= get_xml_size_limit # Size check (big XML data cannot be parsed to DOM)
					yield Nokogiri::XML(data)
				else
					raise "XML data too large."
				end
			end
		end

		def xml_load(url, options = {})

			# Possibly override driver
			driver = options[:driver] ? options[:driver] : get_driver

			if ![:xml, :xml_gzip, :xml_folder_zip].include?(driver)
				raise "Can't call xml_load for driver '#{driver}'."
			end

			# Require
			require "nokogiri"
			
			# Get raw data from remote server
			response = load_from_url(url)
			
			# Parse data into nokogiri document
			if driver == :xml
				xml_parse(response, options) do |root_element|
					yield root_element
				end
				
			elsif driver == :xml_gzip
				require "zlib" 
				
				# Create temp file
				tmp_file = Tempfile.new("import")
				tmp_file.binmode
				tmp_file.write(response)
				tmp_file.seek(0)
				
				# Extract gzip
				extracted_response = Zlib::GzipReader.open(tmp_file.path).read
				xml_parse(extracted_response, options) do |root_element|
					yield root_element
				end
				
				# Delete tempfile
				tmp_file.close
				tmp_file.unlink 

			elsif driver == :xml_folder_zip
				require "zip"

				# Batch
				batch_size = get_batch_size
				batch_enabled = (!batch_size.nil?)
				
				# Create temp file
				tmp_file = Tempfile.new("import")
				tmp_file.binmode
				tmp_file.write(response)
				tmp_file.seek(0)

				# Get current batch state
				if batch_enabled
					batch_state = init_subject_batch 
				end

				# Extract zip
				Zip::File.open(tmp_file.path) do |zip_file|
					file_index = 0
					zip_file.each do |entry|
						if entry.name.ends_with?(".xml")

							# File size check (big files cannot be parsed to DOM)
							if (entry.size / 1048576) <= get_xml_size_limit

								# Batch management => yield if inside current batch or batch not enabled
								if !batch_enabled || (file_index >= batch_state && file_index < (batch_state + batch_size))
									xml_parse(entry.get_input_stream.read, options) do |root_element|
										yield root_element
									end
								
								elsif batch_enabled && (file_index >= (batch_state + batch_size))
									@next_batch = true # Remember that another batch is necessary to complete operation
								end
								
								# Index
								file_index += 1

							else
								#raise "XML file too large."
							end

						end
					end
				end

				# Save new batch state
				finish_subject_batch(@next_batch ? (batch_state + batch_size) : nil) if batch_enabled

				# Delete tempfile
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
		# TXT
		# *************************************************************************

		def txt_load(url, options = {})

			# Possibly override driver
			driver = options[:driver] ? options[:driver] : get_driver

			if ![:txt, :txt_gzip, :txt_folder_zip].include?(driver)
				raise "Can't call txt_load for driver '#{driver}'."
			end

			# Load content of ZIP file
			response = load_from_url(url)

			# Table delimiter
			table_delimiter = options[:table_delimiter] ? options[:table_delimiter] : nil

			if driver == :txt
				raise "Not implemented yet"

			elsif driver == :txt_gzip
				require "zlib" 
				
				# Create temp file
				tmp_file = Tempfile.new("import")
				tmp_file.binmode
				tmp_file.write(response)
				tmp_file.seek(0)
				
				# Extract gzip
				table_index = 0
				line_index = 0
				Zlib::GzipReader.open(tmp_file.path).each_line do |data|
					if table_delimiter && data.include?(table_delimiter)
						table_index += 1
						line_index = 0
					else
						yield nil, table_index, line_index, data
						line_index += 1
					end
				end
				
				# Delete tempfile
				tmp_file.close
				tmp_file.unlink 
			
			elsif driver == :txt_folder_zip
				require "zip"

				# Create temp file
				tmp_file = Tempfile.new("import")
				tmp_file.binmode
				tmp_file.write(response)
				tmp_file.seek(0)
				
				# Extract ZIP file
				Zip::File.open(tmp_file.path) do |zip_file|
					if options[:filenames]
						options[:filenames].each_with_index do |filename, file_index|
							entry = zip_file.find_entry(filename)
							if entry
								table_index = 0
								line_index = 0
								entry.get_input_stream.each_line do |data|
									if table_delimiter && data.include?(table_delimiter)
										table_index += 1
										line_index = 0
									else
										yield file_index, table_index, line_index, data
										line_index += 1
									end
								end
							end
						end
					else
						zip_file.each do |entry|
							table_index = 0
							line_index = 0
							entry.get_input_stream.each_line do |data|
								if table_delimiter && data.include?(table_delimiter)
									table_index += 1
									line_index = 0
								else
									yield nil, table_index, line_index, data
									line_index += 1
								end
							end
						end
					end
				end

				# Delte tempfile
				tmp_file.close
				tmp_file.unlink
			end
			
			return true
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
				deactivated_logger.info("Progress #{@progress_label}: #{@progress_current.to_s}#{@progress_count.nil? ? "" : "/" + @progress_count.to_s}")
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
				deactivated_logger.info("Progress #{@progress_label}: tick #{@progress_current.to_s}")
			end
		end

		# *************************************************************************
		# Subject
		# *************************************************************************

		#
		# To be overridden
		#
		def subject
			nil
		end

		def init_subject
			if self.subject
				self.subject.last_import_at = Time.current
				self.subject.last_import_state = "in_progress"
				self.subject.save
			end
		end

		def finish_subject(error = false, error_message = nil)
			if self.subject
				if error
					self.subject.last_import_state = "error"
					self.subject.last_import_message = error_message
				else
					self.subject.last_import_state = "success"
					self.subject.last_import_message = nil
				end
				time_begin = self.subject.last_import_at
				time_end = Time.current
				if @prev_batch == true
					self.subject.last_import_duration = self.subject.last_import_duration.to_i + (time_end - time_begin)
				else
					self.subject.last_import_duration = (time_end - time_begin)
				end
				self.subject.last_import_at = time_end
				self.subject.save
			end
		end

		def init_subject_batch
			if self.subject
				result = self.subject.last_import_batch_state.to_i
				@prev_batch = (result != 0)
				@next_batch = false
				return result
			else
				return 0
			end
		end

		def finish_subject_batch(batch_state)
			if self.subject
				self.subject.last_import_batch_state = batch_state
				self.subject.save
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