# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

gem 'config'
gem 'http'
gem 'nokogiri'
gem 'rake'
gem 'require_all'
gem 'uuidtools'

group :development, :test do
  gem 'json-schema'
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec'
  gem 'webmock'
  gem 'byebug'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'dlss-capistrano'
  gem 'capistrano-rvm'
end
