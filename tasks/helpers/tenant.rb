# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by tenant_settings rake tasks
module TenantTaskHelpers
  include FolioRequestHelper

  # Institutions
  def institutions_csv
    CSV.parse(File.open("#{Settings.tsv}/tenant/institutions.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def institutions_post(obj)
    @@folio_request.post('/location-units/institutions', obj.to_json)
  end

  # Campuses
  def campuses_csv
    CSV.parse(File.open("#{Settings.tsv}/tenant/campuses.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def campus_hash(obj, institution_uuid)
    obj['institutionId'] = institution_uuid

    obj
  end

  def campuses_post(obj)
    @@folio_request.post('/location-units/campuses', obj.to_json)
  end

  # Libraries
  def libraries_csv
    CSV.parse(File.open("#{Settings.tsv}/tenant/libraries.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def library_hash(obj, campus_uuid_map)
    campus_uuid = campus_uuid_map.fetch(obj['campus'])

    obj['campusId'] = campus_uuid
    obj.delete('campus')
    obj
  end

  def libraries_post(obj)
    @@folio_request.post('/location-units/libraries', obj.to_json)
  end

  #  Service points
  def service_points_csv
    CSV.parse(File.open("#{Settings.tsv}/tenant/service-points.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def service_points_hash(obj)
    duration = obj['holdShelfExpiryPeriod']
    interval = obj['intervalId']

    if obj['pickupLocation'].casecmp('true').zero?
      (obj['holdShelfExpiryPeriod'] = { 'duration' => duration, 'intervalId' => interval })
    end

    obj['staffSlips'] = [
      { 'id' => hold_cql, 'printByDefault' => obj['printDefaultHold'] },
      { 'id' => transit_cql, 'printByDefault' => obj['printDefaultTransit'] },
      { 'id' => pick_slip_cql, 'printByDefault' => obj['printDefaultPickSlip'] },
      { 'id' => request_delivery_cql, 'printByDefault' => obj['printDefaultRequestDelivery'] }
    ]

    obj.delete('intervalId')
    obj.delete('printDefaultHold')
    obj.delete('printDefaultTransit')
    obj.delete('printDefaultPickSlip')
    obj.delete('printDefaultRequestDelivery')

    obj.compact
  end

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
  def locations_csv
    CSV.parse(File.open("#{Settings.tsv}/tenant/locations.tsv"), headers: true, col_sep: "\t",
                                                                 quote_char: nil).map(&:to_h)
  end

  def locations_hash(obj, uuid_maps)
    inst_uuid_map, campus_uuid_map, library_uuid_map, svc_pnt_uuid_map = uuid_maps
    service_point = svc_pnt_uuid_map.fetch(obj['primaryServicePointCode'])

    obj['institutionId'] = inst_uuid_map.fetch(obj['institutionCode'])
    obj['libraryId'] = library_uuid_map.fetch(obj['libraryCode'])
    obj['campusId'] = campus_uuid_map.fetch(obj['campusCode'])
    obj['primaryServicePoint'] = service_point
    obj['servicePointIds'] = [service_point]

    obj.delete('institutionCode')
    obj.delete('campusCode')
    obj.delete('libraryCode')
    obj.delete('primaryServicePointCode')

    obj.compact
  end

  def locations_post(obj)
    @@folio_request.post('/locations', obj.to_json)
  end

  def pull_calendars
    hash = @@folio_request.get('/calendar/calendars')
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
