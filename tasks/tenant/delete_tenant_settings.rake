# frozen_string_literal: true

require 'csv'
require_relative '../helpers/tenant'
require_relative '../helpers/uuids/uuids'

namespace :tenant do
  include TenantTaskHelpers, Uuids

  desc 'delete tenant addresses from folio'
  task :delete_tenant_addresses do
    addresses_csv.each do |obj|
      hash = addresses_hash(obj)
      id = Uuids.tenant_addresses.fetch(hash['code'])
      addresses_delete(id)
    end
  end

  desc 'delete location settings from folio'
  task :delete_locations do
    folio = FolioRequest.new

    tsv_contents = CSV.read('tsv/locations.tsv', { col_sep: "\t" })
    tsv_contents.shift
    tsv_contents.each do |row|
      code = row[0]
      locations = folio.get_cql('/locations', "code==#{code}")['locations']
      if locations.empty?
        puts "failed deleting location #{code}"
        next
      else
        id = locations[0]['id']
        print "deleting location #{code}"
        folio.delete("/locations/#{id}")
      end
    end
  end

  desc 'delete service point settings from folio'
  task :delete_service_points do
    folio = FolioRequest.new

    tsv_contents = CSV.read('tsv/service-points.tsv', { col_sep: "\t" })
    tsv_contents.shift
    tsv_contents.each do |row|
      code = row[1]
      service_points = folio.get_cql('/service-points', "code==#{code}")['servicepoints']
      if service_points.empty?
        puts "failed deleting service point #{code}"
        next
      else
        id = service_points[0]['id']
        print "deleting service point #{code}"
        folio.delete("/service-points/#{id}")
      end
    end
  end

  desc 'delete library settings from folio'
  task :delete_libraries do
    folio = FolioRequest.new

    tsv_contents = CSV.read('tsv/libraries.tsv', { col_sep: "\t" })
    tsv_contents.shift
    tsv_contents.each do |row|
      code = row[2]
      libraries = folio.get_cql('/location-units/libraries', "code==#{code}")['loclibs']
      if libraries.empty?
        puts "failed deleting library #{code}"
        next
      else
        id = libraries[0]['id']
        print "deleting library #{code}"
        folio.delete("/location-units/libraries/#{id}")
      end
    end
  end

  desc 'delete campus settings from folio'
  task :delete_campuses do
    folio = FolioRequest.new

    tsv_contents = CSV.read('tsv/campuses.tsv', { col_sep: "\t" })
    tsv_contents.shift
    tsv_contents.each do |row|
      code = row[1]
      campuses = folio.get_cql('/location-units/campuses', "code==#{code}")['loccamps']
      if campuses.empty?
        puts "failed deleting campus #{code}"
        next
      else
        id = campuses[0]['id']
        print "deleting campus #{code}"
        folio.delete("/location-units/campuses/#{id}")
      end
    end
  end

  desc 'delete institution settings from folio'
  task :delete_institutions do
    folio = FolioRequest.new

    tsv_contents = CSV.read('tsv/institutions.tsv', { col_sep: "\t" })
    tsv_contents.shift
    tsv_contents.each do |row|
      code = row[1]
      institutions = folio.get_cql('/location-units/institutions', "code==#{code}")['locinsts']
      if institutions.empty?
        puts "failed deleting institution #{code}"
        next
      else
        id = institutions[0]['id']
        print "deleting institution #{code}"
        folio.delete("/location-units/institutions/#{id}")
      end
    end
  end
end
