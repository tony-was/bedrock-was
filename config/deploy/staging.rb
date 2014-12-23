#set unique application name for staging and production to avoid permission problems when running deploy:check
set :application, 'staging.application.com'

#set remote deploy path
set :deploy_to, -> { "/home/staging-application" }

#set remote server details
server 'web.server.ip', user: 'staging-username', roles: %w{web app db}

set :stage, :staging
set :log_level, :info
set :ssh_options, {
  keys: %w(~/.ssh/id_rsa)
}

fetch(:default_env).merge!(wp_env: :staging)