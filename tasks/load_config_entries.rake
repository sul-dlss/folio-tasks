# frozen_string_literal: true

require_relative 'helpers/configurations'

namespace :configurations do
  include ConfigurationsTaskHelpers

  desc 'load module configurations for modules specified in app config'
  task :load_configs do
    load_configs
  end

  desc 'update module configurations for modules specified in app config'
  task :update_configs do
    update_configs
  end

  desc 'load configurations for specified module (see app config for list)'
  task :load_module_configs, [:module] do |_, args|
    load_module_configs(args[:module])
  end

  desc 'update configurations for specified module (see app config for list)'
  task :update_module_configs, [:module] do |_, args|
    update_module_configs(args[:module])
  end
end
