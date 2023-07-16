# frozen_string_literal: true

require_relative '../helpers/configurations'

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

  desc 'load all configurations in configurations json directory'
  task :load_json_configurations do
    Dir.each_child("#{Settings.json}/configurations") do |file|
      config_entry_json(file)['configs'].each do |obj|
        config_entry_post(obj)
      end
    end
  end

  desc 'load sip2 configurations info folio'
  task :load_sip2_configs do
    sip2_service_points.each do |obj|
      sip2_config_post(sip2_config_json(sip2_service_point_ids(obj)))
    end
  end

  desc 'load email configuration'
  task :load_email_config do
    email_configuration['smtpConfigurations'].each { |config| email_config_post(config) }
  end
end
