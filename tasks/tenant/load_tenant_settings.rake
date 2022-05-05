# frozen_string_literal: true

require 'csv'
require_relative '../helpers/tenant'
require_relative '../helpers/uuids'

namespace :tenant do
  include TenantTaskHelpers
  include Uuids

  desc 'load institution settings into folio'
  task :load_institutions do
    institutions_csv.each do |obj|
      institutions_post(obj)
    end
  end

  desc 'load campus settings into folio'
  task :load_campuses do
    institution_uuid = Uuids.institutions.fetch('SU')
    campuses_csv.each do |obj|
      hash = campus_hash(obj, institution_uuid)
      campuses_post(hash)
    end
  end

  desc 'load library settings into folio'
  task :load_libraries do
    campus_uuid_map = Uuids.campuses
    libraries_csv.each do |obj|
      hash = library_hash(obj, campus_uuid_map)
      libraries_post(hash)
    end
  end

  desc 'load service point settings into folio'
  task :load_service_points do
    service_points_csv.each do |obj|
      hash = service_points_hash(obj)
      service_points_post(hash)
    end
  end

  desc 'load location settings into folio'
  task :load_locations do
    tenant_uuid_maps = Uuids.uuid_maps
    locations_csv.each do |obj|
      hash = locations_hash(obj, tenant_uuid_maps)
      locations_post(hash)
    end
  end

  desc 'load tenant addresses into folio'
  task :load_tenant_addresses do
    addresses_csv.each do |obj|
      hash = addresses_hash(obj)
      addresses_post(hash)
    end
  end
end
