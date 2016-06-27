namespace :log do

	namespace :production do

		desc "Clean production log."
		task :clean do
			on roles(:app) do
				execute "echo \"\" > #{shared_path}/log/production.log"
			end
		end

		desc "Download production log."
		task :download do
			on roles(:app) do
				download! "#{shared_path}/log/production.log", "log/production.#{Time.now.strftime('%Y%m%d%H%M%S')}.log"
			end
		end

	end

	namespace :staging do

		desc "Clean staging log."
		task :clean do
			on roles(:app) do
				execute "echo \"\" > #{shared_path}/log/staging.log"
			end
		end

		desc "Download staging log."
		task :download do
			on roles(:app) do
				download! "#{shared_path}/log/staging.log", "log/staging.#{Time.now.strftime('%Y%m%d%H%M%S')}.log"
			end
		end

	end

end
