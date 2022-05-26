# frozen_string_literal: true

require 'csv'
require 'nokogiri'
require 'require_all'
require_relative '../helpers/acq_units'
require_rel '../helpers/organizations'
require_relative '../helpers/uuids/acquisitions'

namespace :acquisitions do
  include OrganizationsTaskHelpers, OrgCategoryTaskHelpers, PhoneNumberHelpers, EmailHelpers,
          AcquisitionsUnitsTaskHelpers, AcquisitionsUuidsHelpers

  desc 'load organizations categories into folio'
  task :load_org_categories do
    categories_csv.each do |obj|
      categories_post(obj)
    end
  end

  desc 'load SUL vendor organizations into folio'
  task :load_org_vendors_sul do
    acq_unit = 'SUL'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_sul.xml').each do |obj|
      hash = organization_hash(obj, acq_unit, acq_unit_uuid, map)
      organizations_post(hash)
    end
  end

  desc 'load Business vendor organizations into folio'
  task :load_org_vendors_business do
    acq_unit = 'Business'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_bus.xml').each do |obj|
      hash = organization_hash(obj, acq_unit, acq_unit_uuid, map)
      organizations_post(hash)
    end
  end

  desc 'load Law vendor organizations into folio'
  task :load_org_vendors_law do
    acq_unit = 'Law'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_law.xml').each do |obj|
      hash = organization_hash(obj, acq_unit, acq_unit_uuid, map)
      organizations_post(hash)
    end
  end
end
