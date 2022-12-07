# frozen_string_literal: true

require_relative 'helpers/configurations'

namespace :configurations do
  include ConfigurationsTaskHelpers

  desc 'load module configurations'
  task :load_configurations do
    Dir.each_child("#{Settings.json}/configurations") do |file|
      config_entry_json(file)['configs'].each do |obj|
        config_entry_post(updated_config_entry_json(obj))
      end
    end
  end

  desc 'load configurations for specified module: BULKEDIT CHECKOUT FAST_ADD ORDERS ORG SMTP_SERVER TENANT USERSBL'
  task :load_module_configurations, [:module] do |_, args|
    file = "#{args[:module]}.json"
    config_entry_json(file)['configs'].each do |obj|
      config_entry_post(updated_config_entry_json(obj))
    end
  end

  desc 'update configurations for specified module: BULKEDIT CHECKOUT FAST_ADD ORDERS ORG SMTP_SERVER TENANT USERSBL'
  task :update_module_configurations, [:module] do |_, args|
    file = "#{args[:module]}.json"
    config_entry_json(file)['configs'].each do |obj|
      config_entry_put(updated_config_entry_json(obj))
    end
  end
end
