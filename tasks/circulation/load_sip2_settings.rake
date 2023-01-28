# frozen_string_literal: true

require_relative '../helpers/circulation'

namespace :circulation do
  include CirculationTaskHelpers

  desc 'load sip2 configurations info folio'
  task :load_sip2_configs do
    sip2_service_points.each do |obj|
      sip2_config_post(sip2_config_json(sip2_service_point_ids(obj)))
    end
  end
end
