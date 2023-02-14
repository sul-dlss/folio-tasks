# frozen_string_literal: true

require_relative '../folio_request'

# Folio UUIDs
module Uuids
  include FolioRequestHelper

  def campuses
    campuses_hash = {}
    @@folio_request.get('/location-units/campuses?limit=999')['loccamps'].each do |obj|
      campuses_hash[obj['code']] = obj['id']
    end
    campuses_hash
  end

  def institutions
    institutions_hash = {}
    @@folio_request.get('/location-units/institutions')['locinsts'].each do |obj|
      institutions_hash[obj['code']] = obj['id']
    end
    institutions_hash
  end

  def libraries
    libraries_hash = {}
    @@folio_request.get('/location-units/libraries?limit=99')['loclibs'].each do |obj|
      libraries_hash[obj['code']] = obj['id']
    end
    libraries_hash
  end

  def law_locations
    locations_hash = {}
    campus_id = campuses.fetch('LAW')
    @@folio_request.get("/locations?limit=500&query=campusId=#{campus_id}")['locations'].each do |obj|
      locations_hash[obj['code']] = obj['id']
    end
    locations_hash
  end

  def sul_locations
    locations_hash = {}
    campus_id = campuses.fetch('SUL')
    @@folio_request.get("/locations?limit=500&query=campusId=#{campus_id}")['locations'].each do |obj|
      locations_hash[obj['code']] = obj['id']
    end
    locations_hash
  end

  def material_types
    material_types_hash = {}
    @@folio_request.get('/material-types?limit=99')['mtypes'].each do |obj|
      material_types_hash[obj['name']] = obj['id']
    end
    material_types_hash
  end

  def note_types
    note_types = {}
    @@folio_request.get('/note-types?limit=99')['noteTypes'].each do |obj|
      note_types[obj['name']] = obj['id']
    end
    note_types
  end

  def payment_owners
    owners_hash = {}
    @@folio_request.get('/owners?limit=99')['owners'].each do |obj|
      owners_hash[obj['owner']] = obj['id']
    end
    owners_hash
  end

  def service_points
    service_points_hash = {}
    @@folio_request.get('/service-points?limit=999')['servicepoints'].each do |obj|
      service_points_hash[obj['code']] = obj['id']
    end
    service_points_hash
  end

  def service_point_names
    service_points_hash = {}
    @@folio_request.get('/service-points?limit=999')['servicepoints'].each do |obj|
      service_points_hash[obj['name']] = obj['id']
    end
    service_points_hash
  end

  def tenant_addresses
    addresses_hash = {}
    @@folio_request.get('/configurations/entries?query=configName==tenant.addresses&limit=99')['configs'].each do |obj|
      addresses_hash[obj['code']] = obj['id']
    end
    addresses_hash
  end

  def config_entries
    hash = {}
    @@folio_request.get('/configurations/entries?limit=99')['configs'].each do |obj|
      hash[obj['code']] = obj['id']
    end
    hash
  end

  def profile_associations_ids
    uuids = []
    associations = JSON.parse(pull_profile_associations)

    associations['profileAssociations'].each do |obj|
      uuids.push(obj['id'])
    end
    uuids
  end

  def user_ids(username)
    user_id = @@folio_request.get("/users?query=username==#{username}")['users'].dig(0, 'id')
    perms_user_id = @@folio_request.get("/perms/users?query=userId==#{user_id}")['permissionUsers'].dig(0, 'id')
    service_point_user_id = @@folio_request
                            .get("/service-points-users?query=userId==#{user_id}")['servicePointsUsers'].dig(0, 'id')
    [user_id, perms_user_id, service_point_user_id]
  end

  def uuid_maps
    [institutions, campuses, libraries, service_points]
  end
end
