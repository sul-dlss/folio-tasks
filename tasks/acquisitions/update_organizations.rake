# frozen_string_literal: true

require 'csv'
require 'require_all'
require_relative '../helpers/acq_units'
require_rel '../helpers/organizations'
require_relative '../helpers/uuids/acquisitions'

namespace :acquisitions do
  include OrganizationsTaskHelpers, OrgCategoryTaskHelpers, AddressHelpers, AcquisitionsUnitsTaskHelpers,
          AcquisitionsUuidsHelpers

  desc 'update SUL organizations in folio'
  task :update_org_vendors_sul do
    acq_unit = 'SUL'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_sul.xml').each do |obj|
      hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, map)
      id = organizations_id(hash['code'])
      organizations_put(id, hash) unless id.nil?
    end
  end

  desc 'update Business organizations in folio'
  task :update_org_vendors_business do
    acq_unit = 'Business'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_bus.xml').each do |obj|
      hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, map)
      id = organizations_id(hash['code'])
      organizations_put(id, hash) unless id.nil?
    end
  end

  desc 'update Law organizations in folio'
  task :update_org_vendors_law do
    acq_unit = 'Law'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_law.xml').each do |obj|
      hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, map)
      id = organizations_id(hash['code'])
      organizations_put(id, hash) unless id.nil?
    end
  end
end
