#set unique application name for staging and production to avoid permission problems when running deploy:check
set :application, 'staging.application.com'
set :user, 'staging-username'

#set remote deploy path
set :deploy_to, -> { "/home/staging-application" }

#set remote server details
server 'web.server.ip', user: fetch(:user), roles: %w{web app db}

set :stage, :staging
set :log_level, :info

set :ssh_options, {
  keys: %w(~/.ssh/id_rsa)
}

fetch(:default_env).merge!(wp_env: :staging)

namespace :migrate do
  namespace :push do
    desc "Uploads both local database & syncs local files into remote"
    task :all => ["push:db", "push:files"]
    desc "Uploads local database into remote"
    task :db do
      on roles(:web) do
        run_locally do
          within fetch(:vagrant_root) do
            execute :vagrant, :up
            execute "ssh vagrant@#{fetch(:dev_application)} 'cd /home/vagrant/sites/#{fetch(:dev_application)} && wp db export - | gzip > #{fetch(:base_db_filename)}.gz'"
          end
        end
        upload! "#{fetch(:base_db_filename)}.gz", "#{fetch(:deploy_to)}/#{fetch(:base_db_filename)}.gz"
        execute :gunzip, "#{fetch(:deploy_to)}/#{fetch(:base_db_filename)}.gz"
        execute "pwd"
        execute "cd #{fetch(:deploy_to)}/current && wp db import #{fetch(:deploy_to)}/#{fetch(:base_db_filename)}"
        execute "pwd"
        execute "cd #{fetch(:deploy_to)}/current && wp search-replace #{fetch(:dev_application)} #{fetch(:application)}"
        execute :rm, "#{fetch(:deploy_to)}/#{fetch(:base_db_filename)}"
        run_locally do
          execute "rm #{fetch(:base_db_filename)}.gz"
        end
      end
    end
    task :files do
      on roles(:web) do
        within shared_path do
          system("rsync -a --del -L -K -vv --progress --rsh='ssh -p 22' ./web/app/uploads #{fetch(:user)}@#{fetch(:application)}:#{shared_path}/web/app")
        end
      end
    end
  end
end