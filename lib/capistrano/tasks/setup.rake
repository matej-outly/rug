namespace :setup do

	desc "Upload database.yml file."
	task :upload_database_yml do
		on roles(:app) do
			execute "mkdir -p #{shared_path}/config"
			upload! StringIO.new(File.read("config/database.yml.example")), "#{shared_path}/config/database.yml"
		end
	end

	desc "Upload entypo fonts."
	task :upload_entypo do
		on roles(:web) do
			execute "mkdir -p #{shared_path}/public/fonts/icons"
			upload! "vendor/assets/libraries/gumby/fonts/icons/entypo.eot", "#{shared_path}/public/fonts/icons/entypo.eot"
			upload! "vendor/assets/libraries/gumby/fonts/icons/entypo.ttf", "#{shared_path}/public/fonts/icons/entypo.ttf"
			upload! "vendor/assets/libraries/gumby/fonts/icons/entypo.woff", "#{shared_path}/public/fonts/icons/entypo.woff"
		end
	end

	desc "Upload gumby CSS and JS."
	task :upload_gumby do
		on roles(:web) do
			execute "mkdir -p #{shared_path}/public/assets/gumby/css"
			execute "mkdir -p #{shared_path}/public/assets/gumby/js/libs"
			upload! "vendor/assets/libraries/gumby/css/gumby.css", "#{shared_path}/public/assets/gumby/css/gumby.css"
			upload! "vendor/assets/libraries/gumby/js/libs/jquery.mobile.custom.min.js", "#{shared_path}/public/assets/gumby/js/libs/jquery.mobile.custom.min.js"
		end
	end

end

desc 'Setup a new release.'
task :setup do
	%w{ upload_database_yml upload_entypo upload_gumby }.each do |task|
		invoke "setup:#{task}"
	end
end