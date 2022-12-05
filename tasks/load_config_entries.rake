# frozen_string_literal: true

require_relative 'helpers/configurations'

namespace :configurations do
  include ConfigurationsTaskHelpers

  desc 'load module configurations'
  task :load_configurations do
    Dir.each_child("#{Settings.json}/configurations") do |file|
      config_entry_json(file)['configs'].each do |obj|
        config_entry_post(obj)
      end
    end
  end

  desc 'load configurations for specified module: BULKEDIT CHECKOUT FAST_ADD ORG TENANT'
  task :load_module_configurations, [:module] do |_, args|
    file = "#{args[:module]}.json"
    config_entry_json(file)['configs'].each do |obj|
      config_entry_post(obj)
    end
  end
end
