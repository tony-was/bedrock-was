#set unique application name for staging and production to avoid permission problems when running deploy:check
set :application, 'application.com'
set :user, 'username'

#set remote deploy path
set :deploy_to, -> { "/home/application" }

#set remote server details
server 'web.server.ip', user: fetch(:user), roles: %w{web app db}

set :stage, :production
set :log_level, :info

set :ssh_options, {
  keys: %w(~/.ssh/id_rsa)
}

fetch(:default_env).merge!(wp_env: :production)