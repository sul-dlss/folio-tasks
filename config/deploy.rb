# frozen_string_literal: true

set :application, 'folio-tasks'
set :github_token, `git config --get github.token | tr -d '\n'`
set :repo_url, "https://#{fetch(:github_token)}@github.com/sul-dlss/folio-tasks.git"
set :user, 'sirsi'

# Default branch is :main
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default value for :log_level is :debug
set :log_level, :info

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/s/SUL/Bin/#{fetch(:application)}"

set :linked_dirs,
    %w[config/settings userload-harvest/src/main/resources userload-harvest/jar userload-harvest/etc userload-harvest/certs userload-harvest/log userload-harvest/out
       userload-harvest/WebLogic_lib]

# Default value for keep_releases is 5
set :keep_releases, 3

set :rvm_ruby_version, '2.7.1'

namespace :deploy do
  desc 'deploy folio-tasks'
  task :config do
    on roles(:app) do
      upload! "config/settings/#{fetch(:stage)}.yml", "#{release_path}/config/settings"
    end
  end
end
