# frozen_string_literal: true

require_relative '../helpers/tenant'

namespace :tenant do
  include TenantTaskHelpers

  desc 'load locations into folio'
  task :load_locations do
    locations_json['locations'].each do |obj|
      locations_post(obj)
    end
  end

  desc 'load calendars into folio'
  task :load_calendars do
    calendars_json['calendars'].each do |obj|
      calendars_post(obj)
    end
  end
end
