# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by tenant_settings rake tasks
module TenantTaskHelpers
  include FolioRequestHelper

  # Institutions
  def institutions_post(obj)
    @@folio_request.post('/location-units/institutions', obj.to_json)
  end

  # Campuses
  def campuses_post(obj)
    @@folio_request.post('/location-units/campuses', obj.to_json)
  end

  # Libraries
  def libraries_post(obj)
    @@folio_request.post('/location-units/libraries', obj.to_json)
  end

  #  Service points
  def hold_cql
    @@folio_request.get_cql('/staff-slips-storage/staff-slips', 'name==Hold')['staffSlips'][0]['id']
  end

  def transit_cql
    @@folio_request.get_cql('/staff-slips-storage/staff-slips', 'name==Transit')['staffSlips'][0]['id']
  end

  def pick_slip_cql
    @@folio_request.get_cql('/staff-slips-storage/staff-slips', 'name==Pick%20slip')['staffSlips'][0]['id']
  end

  def request_delivery_cql
    @@folio_request.get_cql('/staff-slips-storage/staff-slips', 'name==Request%20delivery')['staffSlips'][0]['id']
  end

  def service_points_post(obj)
    @@folio_request.post('/service-points', obj.to_json)
  end

  #  Locations
  def locations_json
    JSON.parse(File.read("#{Settings.json}/tenant/locations.json"))
  end

  def locations_post(obj)
    @@folio_request.post('/locations', obj.to_json)
  end

  def pull_locations
    hash = @@folio_request.get('/locations?limit=1000')
    trim_hash(hash, 'locations')
    hash.to_json
  end

  # Calendars
  def pull_calendars
    hash = @@folio_request.get('/calendar/calendars?limit=100')
    trim_hash(hash, 'calendars')
    hash.to_json
  end

  def calendars_json
    JSON.parse(File.read("#{Settings.json}/tenant/calendars.json"))
  end

  def calendars_post(obj)
    @@folio_request.post('/calendar/calendars', obj.to_json)
  end
end
