# frozen_string_literal: true

require_relative '../helpers/configurations'

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

  desc 'load sip2 configurations info folio'
  task :load_sip2_configs do
    sip2_service_points.each do |obj|
      sip2_config_post(sip2_config_json(sip2_service_point_ids(obj)))
    end
  end
end
