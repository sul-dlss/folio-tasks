# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'update organizations rake tasks' do
  let(:category_uuids) { AcquisitionsUuidsHelpers.organization_categories }
  let(:update_sul_organizations_task) { Rake.application.invoke_task 'acquisitions:update_org_vendors_sul' }
  let(:update_law_organizations_task) { Rake.application.invoke_task 'acquisitions:update_org_vendors_law' }
  let(:update_bus_organizations_task) { Rake.application.invoke_task 'acquisitions:update_org_vendors_business' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/acquisitions-units/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123" }] }')

    stub_request(:get, 'http://example.com/organizations-storage/categories')
      .with(query: hash_including)
      .to_return(body: '{ "categories": [{ "id": "cat-123" }] }')

    stub_request(:get, 'http://example.com/organizations/organizations')
      .with(query: hash_including)
      .to_return(body: '{ "organizations": [{ "id": "org-123" }] }')

    stub_request(:put, 'http://example.com/organizations/organizations/org-123')
  end

  context 'when updating SUL organizations' do
    let(:xml_doc) { update_sul_organizations_task.send(:organizations_xml, 'acquisitions/vendors_sul.xml') }
    let(:acq_unit_uuid) { Uuids.acq_units.fetch('SUL', nil) }
    let(:org_hash) do
      update_sul_organizations_task.send(:organization_hash_from_xml, xml_doc[1], 'SUL', acq_unit_uuid, category_uuids)
    end

    it 'escapes the parentheses in the vendor ID' do
      update_sul_organizations_task.send(:organizations_id, org_hash['code'])
      expect(WebMock).to have_requested(:get, 'http://example.com/organizations/organizations?query=code==%22FAKE%20%281234%29-SUL%22').at_least_once
    end

    it 'escapes the forward slash in the vendor ID' do
      org_hash = update_sul_organizations_task.send(:organization_hash_from_xml, xml_doc[2], 'SUL', acq_unit_uuid,
                                                    category_uuids)
      update_sul_organizations_task.send(:organizations_id, org_hash['code'])
      expect(WebMock).to have_requested(:get, 'http://example.com/organizations/organizations?query=code==%22BARDI/EUR-SUL%22').at_least_once
    end
  end

  context 'when updating Law organizations' do
    let(:xml_doc) { update_law_organizations_task.send(:organizations_xml, 'acquisitions/vendors_law.xml') }
    let(:acq_unit_uuid) { Uuids.acq_units.fetch('Law', nil) }
    let(:org_hash) do
      update_law_organizations_task.send(:organization_hash_from_xml, xml_doc[0], 'Law', acq_unit_uuid, category_uuids)
    end

    it 'escapes the spaces in the vendor ID' do
      update_law_organizations_task.send(:organizations_id, org_hash['code'])
      expect(WebMock).to have_requested(:get, 'http://example.com/organizations/organizations?query=code==%22YALE%20LAW%20REPORT-Law%22').at_least_once
    end
  end

  context 'when updating Business organizations' do
    let(:xml_doc) { update_bus_organizations_task.send(:organizations_xml, 'acquisitions/vendors_bus.xml') }
    let(:acq_unit_uuid) { Uuids.acq_units.fetch('Business', nil) }
    let(:org_hash) do
      update_bus_organizations_task.send(:organization_hash_from_xml, xml_doc[0], 'Business', acq_unit_uuid,
                                         category_uuids)
    end

    it 'escapes the ampersand in the vendor ID' do
      update_bus_organizations_task.send(:organizations_id, org_hash['code'])
      expect(WebMock).to have_requested(:get, 'http://example.com/organizations/organizations?query=code==%22D%26B-Business%22').at_least_once
    end
  end
end
