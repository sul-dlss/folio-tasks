# frozen_string_literal: true

require 'csv'
require 'nokogiri'
require 'require_all'
require_relative '../helpers/acq_units'
require_rel '../helpers/organizations'
require_relative '../helpers/uuids/acquisitions'
require_relative '../../lib/folio_uuid'

namespace :organizations do
  include OrganizationsTaskHelpers, OrgCategoryTaskHelpers, PhoneNumberHelpers, EmailHelpers,
          AcquisitionsUnitsTaskHelpers, AcquisitionsUuidsHelpers, InterfacesHelpers, OrgNoteTaskHelpers

  desc 'load organizations categories into folio'
  task :load_categories do
    categories_csv.each do |obj|
      categories_post(obj)
    end
  end

  desc 'load organizations note types into folio'
  task :load_note_types do
    org_note_types_post
  end

  desc 'load migration error org into folio'
  task :load_vendors_migrate_err do
    AcquisitionsUuidsHelpers.acq_units.slice('SUL', 'Law').each do |name, uuid|
      organizations_post(migrate_error_orgs(name, uuid))
    end
  end

  desc 'load interfaces into folio'
  task :load_interfaces do
    interfaces_json['interfaces'].each do |obj|
      interface_post(obj)
    end
  end

  desc 'load interface credentials into folio'
  task :load_credentials do
    credentials_json['credentials'].each do |obj|
      interface_id = obj['interfaceId']
      credential_post(interface_id, obj)
    end
  end

  desc 'load SUL vendor organizations into folio'
  task :load_vendors_sul do
    acq_unit = 'SUL'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    category_uuids = AcquisitionsUuidsHelpers.organization_categories
    note_type_uuid = org_note_type_id
    organizations_xml('vendors_sul.xml').each do |obj|
      org_hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, category_uuids)
      organizations_post(org_hash)
      add_org_notes(obj, org_hash['id'], note_type_uuid)
    end
  end

  desc 'load CORAL organizations into folio'
  task :load_coral do
    acq_unit = 'SUL'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    organizations_tsv('CORAL_organizations.tsv').each do |obj|
      obj = organization_hash_update(obj, acq_unit_uuid)
      organizations_post(obj)
    end
  end

  desc 'load Business vendor organizations into folio'
  task :load_vendors_business do
    acq_unit = 'Business'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    category_uuids = AcquisitionsUuidsHelpers.organization_categories
    note_type_uuid = org_note_type_id
    organizations_xml('vendors_bus.xml').each do |obj|
      org_hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, category_uuids)
      organizations_post(org_hash)
      add_org_notes(obj, org_hash['id'], note_type_uuid)
    end
  end

  desc 'load Law vendor organizations into folio'
  task :load_vendors_law do
    acq_unit = 'Law'
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch(acq_unit, nil)
    category_uuids = AcquisitionsUuidsHelpers.organization_categories
    note_type_uuid = org_note_type_id
    organizations_xml('vendors_law.xml').each do |obj|
      org_hash = organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, category_uuids)
      organizations_post(org_hash)
      add_org_notes(obj, org_hash['id'], note_type_uuid)
    end
  end
end
