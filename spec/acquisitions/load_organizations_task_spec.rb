# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'organizations rake tasks' do
  let(:load_categories_task) { Rake.application.invoke_task 'acquisitions:load_org_categories' }
  let(:load_migrate_err_task) { Rake.application.invoke_task 'acquisitions:load_org_migrate_err' }
  let(:category_uuids) { AcquisitionsUuidsHelpers.organization_categories }
  let(:load_organizations_task) { Rake.application.invoke_task 'acquisitions:load_org_vendors_sul' }
  let(:load_law_organizations_task) { Rake.application.invoke_task 'acquisitions:load_org_vendors_law' }
  let(:load_bus_organizations_task) { Rake.application.invoke_task 'acquisitions:load_org_vendors_business' }
  let(:load_coral_organizations_task) { Rake.application.invoke_task 'acquisitions:load_org_coral' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/organizations-storage/categories')

    stub_request(:get, 'http://example.com/acquisitions-units/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123", "name": "SUL" },
                                                { "id": "acq-123", "name": "Law" },
                                                { "id": "acq-123", "name": "Business" }] }')

    stub_request(:get, 'http://example.com/organizations-storage/categories')
      .with(query: hash_including)
      .to_return(body: '{ "categories": [{ "id": "cat-123", "value": "Claims" },
                                         { "id": "cat-456", "value": "Orders" },
                                         { "id": "cat-789", "value": "Payments" }] }')

    stub_request(:post, 'http://example.com/organizations/organizations')
  end

  context 'when loading organizations categories' do
    it 'creates the hash key and value for category' do
      expect(load_categories_task.send(:categories_csv)[0]['value']).to eq 'Claims'
    end

    it 'creates the hash key and value for id' do
      expect(load_categories_task.send(:categories_csv)[0]['id']).to eq 'abc-123'
    end
  end

  context 'when loading migration error organizations' do
    let(:org_hash) { load_migrate_err_task.send(:migrate_error_orgs, 'SUL', 'acq-123') }

    it 'creates the hash key and value for name' do
      expect(org_hash['name']).to eq 'SUL Migration Error'
    end

    it 'creates the hash key and value for code' do
      expect(org_hash['code']).to eq 'MIGRATE-ERR-SUL'
    end

    it 'creates the hash key and value for acqUnitIds' do
      expect(org_hash['acqUnitIds']).to include 'acq-123'
    end
  end

  context 'when loading SUL organization data' do
    let(:xml_doc) { load_organizations_task.send(:organizations_xml, 'acquisitions/vendors_sul.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      load_organizations_task.send(:organization_hash_from_xml, xml_doc[0], 'SUL', acq_unit_uuid, category_uuids)
    end

    it 'creates the hash key and value for name' do
      expect(org_hash['name']).to eq 'Carpe Diem Fine Books'
    end

    it 'creates the hash key and value for code' do
      expect(org_hash['code']).to eq 'CARPEDIEM-SUL'
    end

    it 'creates the hash key and value for exportToAccounting' do
      expect(org_hash['exportToAccounting']).to be_truthy
    end

    it 'creates the hash key and value for status' do
      expect(org_hash['status']).to eq 'Active'
    end

    it 'creates the hash key and value for isVendor' do
      expect(org_hash['isVendor']).to be_truthy
    end

    it 'creates the hash key and value for erpCode' do
      expect(org_hash['erpCode']).to eq '123456FEEDER'
    end

    it 'creates the hash key and value for acqUnitIds' do
      expect(org_hash['acqUnitIds']).to include 'acq-123'
    end

    it 'creates an array of address hashes' do
      expect(org_hash['addresses']).to be_a(Array)
    end

    it 'creates an address object with hash key and value for addressLine1' do
      expect(org_hash['addresses'][0]['addressLine1']).to eq '1234 Pearl Street'
    end

    it 'creates an address object with hash key and value for city' do
      expect(org_hash['addresses'][0]['city']).to eq 'Monterey'
    end

    it 'creates an address object with hash key and value for stateRegion' do
      expect(org_hash['addresses'][0]['stateRegion']).to eq 'CA'
    end

    it 'creates an address object with hash key and value for zipCode' do
      expect(org_hash['addresses'][0]['zipCode']).to eq '93940'
    end

    it 'creates an address object with hash key and value for country' do
      expect(org_hash['addresses'][0]['country']).to eq 'USA'
    end

    it 'creates an address object with a primary address' do
      expect(org_hash['addresses'][0]['isPrimary']).to be_truthy
    end

    it 'does not create empty address hash key value pairs' do
      expect(org_hash['addresses'][1]).not_to have_key 'country'
    end

    it 'assigns a category to the address' do
      expect(org_hash['addresses'][0]['categories']).to include 'cat-123'
    end

    it 'does not create empty hash key value pairs for category' do
      expect(org_hash['addresses'][1]).not_to have_key 'categories'
    end

    it 'creates an array of phone number hashes' do
      expect(org_hash['phoneNumbers']).to be_a(Array)
    end

    it 'creates a phone object with a primary phone number' do
      expect(org_hash['phoneNumbers'][0]['isPrimary']).to be_truthy
    end

    it 'creates a phoneNumbers object with hash key and value for phoneNumber' do
      expect(org_hash['phoneNumbers'][0]['phoneNumber']).to eq 'tel: 831-555-5555  cel: 831-555-5555'
    end

    it 'creates a phoneNumbers object with hash key and value for office type' do
      expect(org_hash['phoneNumbers']).to include(a_hash_including('type' => 'Office'))
    end

    it 'creates a phoneNumbers object with hash key and value for fax type' do
      expect(org_hash['phoneNumbers']).to include(a_hash_including('type' => 'Fax'))
    end

    it 'does not add to the phoneNumbers object if no phoneNumber' do
      expect(org_hash['phoneNumbers'].size).to eq 2
    end

    it 'creates an array of email hashes' do
      expect(org_hash['emails']).to be_a(Array)
    end

    it 'creates an array with 3 email addresses' do
      expect(org_hash['emails'].size).to eq 2
    end

    it 'creates an emails object with hash key and value for value' do
      expect(org_hash['emails']).to include(a_hash_including('value' => 'carpediem@example.com'))
    end

    it 'creates an email object with hash key and value for primary email' do
      expect(org_hash['emails']).to include(a_hash_including('value' => 'claims_carpediem@example.com',
                                                             'isPrimary' => true))
    end

    it 'creates the hash key and value for claimingInterval' do
      expect(org_hash['claimingInterval']).to eq 364
    end

    it 'creates the hash key and value for vendorCurrencies' do
      expect(org_hash['vendorCurrencies']).to include 'USD'
    end

    it 'creates the hash key and value for liableForVat' do
      expect(org_hash['liableForVat']).to eq true
    end
  end

  context 'when tax is not paid to the vendor' do
    let(:xml_doc) { load_organizations_task.send(:organizations_xml, 'acquisitions/vendors_sul.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      load_organizations_task.send(:organization_hash_from_xml, xml_doc[1], 'SUL', acq_unit_uuid, category_uuids)
    end

    it 'creates the hash key and value for liableForVat' do
      expect(org_hash['liableForVat']).to eq false
    end
  end

  context 'when SUL organization should not export to accounting' do
    let(:xml_doc) { load_organizations_task.send(:organizations_xml, 'acquisitions/vendors_sul.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      load_organizations_task.send(:organization_hash_from_xml, xml_doc[3], 'SUL', acq_unit_uuid, category_uuids)
    end

    it 'creates the hash key and value for exportToAccounting' do
      expect(org_hash['exportToAccounting']).to be_falsey
    end
  end

  context 'when SUL organization is missing data' do
    let(:xml_doc) { load_organizations_task.send(:organizations_xml, 'acquisitions/vendors_sul.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      load_organizations_task.send(:organization_hash_from_xml, xml_doc[1], 'SUL', acq_unit_uuid, category_uuids)
    end

    it 'does not create an address object if no primary address selected' do
      expect(org_hash).not_to have_key 'addresses'
    end

    it 'does not create an emails object if no primary email selected' do
      expect(org_hash).not_to have_key 'emails'
    end

    it 'does not create a phoneNumbers object if no primary phone selected' do
      expect(org_hash).not_to have_key 'phoneNumbers'
    end

    it 'does not create empty claimingInterval hash key value pairs' do
      expect(org_hash).not_to have_key 'claimingInterval'
    end

    it 'does not create empty vendorCurrencies hash key value pairs' do
      expect(org_hash).not_to have_key 'vendorCurrencies'
    end
  end

  context 'when organization has no po/claim email address' do
    let(:xml_doc) { load_organizations_task.send(:organizations_xml, 'acquisitions/vendors_sul.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      load_organizations_task.send(:organization_hash_from_xml, xml_doc[2], 'SUL', acq_unit_uuid, category_uuids)
    end

    it 'creates an email object with hash key and value for primary email' do
      expect(org_hash['emails']).to include(a_hash_including('value' => 'info@example.com',
                                                             'isPrimary' => true))
    end
  end

  context 'when organization has multiple address lines' do
    let(:xml_doc) { load_organizations_task.send(:organizations_xml, 'acquisitions/vendors_sul.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      load_organizations_task.send(:organization_hash_from_xml, xml_doc[3], 'SUL', acq_unit_uuid, category_uuids)
    end

    it 'creates an address object with hash key and value for addressLine1' do
      expect(org_hash['addresses'][0]['addressLine1']).to eq 'Institute of Physics, University of Amsterdam'
    end

    it 'creates an address object with hash key and value for addressLine2' do
      expect(org_hash['addresses'][0]['addressLine2']).to eq 'Postbus 94485'
    end
  end

  context 'when loading Law organization data' do
    let(:xml_doc) { load_law_organizations_task.send(:organizations_xml, 'acquisitions/vendors_law.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('Law', nil) }
    let(:org_hash) do
      load_law_organizations_task.send(:organization_hash_from_xml, xml_doc[0], 'Law', acq_unit_uuid, category_uuids)
    end

    it 'creates the hash key and value for code with spaces' do
      expect(org_hash['code']).to eq 'YALE LAW REPORT-Law'
    end
  end

  context 'when Law organization should not export to accounting' do
    let(:xml_doc) { load_law_organizations_task.send(:organizations_xml, 'acquisitions/vendors_law.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('Law', nil) }
    let(:org_hash) do
      load_law_organizations_task.send(:organization_hash_from_xml, xml_doc[1], 'Law', acq_unit_uuid, category_uuids)
    end

    it 'creates the hash key and value for exportToAccounting' do
      expect(org_hash['exportToAccounting']).to be_falsey
    end
  end

  context 'when loading Business organization data' do
    let(:xml_doc) { load_bus_organizations_task.send(:organizations_xml, 'acquisitions/vendors_bus.xml') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('Business', nil) }
    let(:org_hash) do
      load_bus_organizations_task.send(:organization_hash_from_xml, xml_doc[0], 'Business', acq_unit_uuid,
                                       category_uuids)
    end

    it 'creates the hash key and value for code with an ampersand' do
      expect(org_hash['code']).to eq 'D&B-Business'
    end

    it 'does not create empty claimingInterval hash key value pairs' do
      expect(org_hash).not_to have_key 'claimingInterval'
    end
  end

  context 'when loading a CORAL organization data with all fields' do
    let(:coral_tsv) { load_coral_organizations_task.send(:organizations_tsv, 'CORAL_organizations.tsv') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      load_coral_organizations_task.send(:organization_hash_update, coral_tsv[0], acq_unit_uuid)
    end

    it 'creates the hash code with SUL appended' do
      expect(org_hash['code']).to eq 'NATUREAMERICA-SUL'
    end

    it 'creates the status to Active' do
      expect(org_hash['status']).to eq 'Active'
    end

    it 'creates an array for aliases' do
      expect(org_hash['aliases']).to eq [{ value: 'Nature America' }]
    end

    it 'creates an array for urls' do
      expect(org_hash['urls']).to eq [{ value: 'http://www.nature.com' }]
    end

    it 'creates acqUnitIds are with value' do
      expect(org_hash['acqUnitIds']).to eq [acq_unit_uuid]
    end
  end

  context 'when loading a CORAL organization data with missing fields' do
    let(:coral_tsv) { load_coral_organizations_task.send(:organizations_tsv, 'CORAL_organizations.tsv') }
    let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      load_coral_organizations_task.send(:organization_hash_update, coral_tsv[1], acq_unit_uuid)
    end

    it 'creates the hash code with SUL appended' do
      expect(org_hash['code']).to eq 'RIGHTFILMS-SUL'
    end

    it 'asserts that aliases is not in hash' do
      expect(org_hash['aliases']).to be_nil
    end

    it 'asserts that urls is not in hash' do
      expect(org_hash['urls']).to be_nil
    end
  end
end
