# frozen_string_literal: true

require 'csv'
require 'require_all'
require_relative '../helpers/acq_units'
require_rel '../helpers/organizations'
require_relative '../helpers/uuids/acquisitions'

namespace :acquisitions do
  include OrganizationsTaskHelpers, OrgCategoryTaskHelpers, AcquisitionsUnitsTaskHelpers, AcquisitionsUuidsHelpers

  desc 'delete SUL organizations from folio'
  task :delete_org_vendors_sul do
    acq_unit = 'SUL'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_sul.xml').each do |obj|
      hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, map)
      id = organizations_id(hash['code'])
      organizations_delete(id)
    end
  end

  desc 'delete Business organizations from folio'
  task :delete_org_vendors_business do
    acq_unit = 'Business'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_bus.xml').each do |obj|
      hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, map)
      id = organizations_id(hash['code'])
      organizations_delete(id)
    end
  end

  desc 'delete Law organizations from folio'
  task :delete_org_vendors_law do
    acq_unit = 'Law'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    map = category_map
    organizations_xml('acquisitions/vendors_law.xml').each do |obj|
      hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, map)
      id = organizations_id(hash['code'])
      organizations_delete(id)
    end
  end
end
