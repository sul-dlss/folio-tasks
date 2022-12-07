# frozen_string_literal: true

require_relative 'helpers/configurations'

namespace :configurations do
  include ConfigurationsTaskHelpers

  desc 'load module configurations'
  task :load_configs do
    Dir.each_child("#{Settings.json}/configurations") do |file|
      config_entry_json(file)['configs'].each do |obj|
        config_entry_post(updated_config_entry_json(obj))
      end
    end
  end

  desc 'load configurations for modules specified in app config'
  task :load_module_configs, [:module] do |_, args|
    file = "#{args[:module]}.json"
    config_entry_json(file)['configs'].each do |obj|
      config_entry_post(updated_config_entry_json(obj))
    end
  end

  desc 'update configurations for modules specified in app config'
  task :update_module_configs, [:module] do |_, args|
    file = "#{args[:module]}.json"
    config_entry_json(file)['configs'].each do |obj|
      config_entry_put(updated_config_entry_json(obj))
    end
  end
end
