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

set :linked_dirs, %w[config/settings Person/src/main/resources Person/jar Person/etc Person/certs log out Person/WebLogic_lib]

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

  desc 'Upload the Person jar files'
  task :jars do
      on roles(:app) do
        upload! "Person/target/Person-jar-with-dependencies.jar" , "#{release_path}/Person/jar"
      end
  end
end
