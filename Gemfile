# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.1'

gem 'config'
gem 'http'
gem 'nokogiri'
gem 'rake'
gem 'require_all'

group :development, :test do
  gem 'json-schema'
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec'
  gem 'webmock'

end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'dlss-capistrano'
  gem 'capistrano-rvm'
end
