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

  desc 'load self-check service points'
  task :load_self_check_service_points do
    self_check_config
  end
end
