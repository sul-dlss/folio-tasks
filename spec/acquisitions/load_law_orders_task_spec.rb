# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load LAW orders rake tasks' do
  let(:load_law_orders_task) { Rake.application.invoke_task 'acquisitions:load_orders_law' }
  let(:acq_unit_uuid) { load_law_orders_task.send(:acq_unit_id, 'Law') }
  let(:order_type_map) do
    load_law_orders_task.send(:order_type_mapping, 'order_type_map.tsv', Uuids.material_types)
  end
  let(:hldg_code_map) do
    load_law_orders_task.send(:hldg_code_map, 'sym_hldg_code_location_map.tsv', Uuids.law_locations)
  end
  let(:uuid_hashes) do
    [Uuids.tenant_addresses, Uuids.law_organizations, order_type_map, hldg_code_map, Uuids.law_funds]
  end
  let(:law_order_yaml_dir) { Settings.yaml.law_orders.to_s }
  let(:order_id) do
    load_law_orders_task.send(:get_id_data, YAML.load_file("#{law_order_yaml_dir}/56789L02.yaml")).shift
  end
  let(:sym_order) do
    load_law_orders_task.send(:get_id_data, YAML.load_file("#{law_order_yaml_dir}/56789L02.yaml")).pop
  end
  let(:orders_hash) { load_law_orders_task.send(:orders_hash, order_id, sym_order, acq_unit_uuid, uuid_hashes) }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/orders/composite-orders')

    stub_request(:get, 'http://example.com/acquisitions-units-storage/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123", "name": "Law" }] }')

    stub_request(:get, 'http://example.com/configurations/entries')
      .with(query: hash_including)
      .to_return(body: '{ "configs": [{ "id": "entry-5678", "code": "LAW_LIBRARY_ACQUISITIONS" }] }')

    stub_request(:get, 'http://example.com/organizations/organizations')
      .with(query: hash_including)
      .to_return(body: '{ "organizations": [{ "id": "org-123", "code": "PCARD-Law" },
                                            { "id": "org-456", "code": "STANFORD-Law" }]
                        }')
    stub_request(:get, 'http://example.com/finance/ledgers')
      .with(query: hash_including)
      .to_return(body: '{ "ledgers": [{ "id": "led-123", "code": "LAW" }] }')

    stub_request(:get, 'http://example.com/finance/funds')
      .with(query: hash_including)
      .to_return(body: '{ "funds": [{ "id": "fund-123", "code": "BLAWFUND" }] }')

    stub_request(:get, 'http://example.com/material-types')
      .with(query: hash_including)
      .to_return(body: '{ "mtypes": [{ "id": "mat-123", "name": "book" },
                                     { "id": "mat-456", "name": "serial" }]
                        }')

    stub_request(:get, 'http://example.com/location-units/campuses?limit=999')
      .to_return(body: '{ "loccamps": [{ "id": "camp-123", "code": "LAW" }]}')

    stub_request(:get, 'http://example.com/locations')
      .with(query: hash_including)
      .to_return(body: '{ "locations": [{ "id": "loc-123", "code": "ART-STACKS" },
                                        { "id": "loc-123", "code": "LAW-MIGRATE-ERR" },
                                        { "id": "loc-123", "code": "GRE-MIGRATE-ERR" },
                                        { "id": "loc-123", "code": "MUS-R-STACKS" },
                                        { "id": "loc-123", "code": "MUS-REF" },
                                        { "id": "loc-123", "code": "SAL3-stacks" },
                                        { "id": "loc-123", "code": "SPEC-MANUSCRIPT" },
                                        { "id": "loc-123", "code": "GRE-MIGRATE-ERR" }]
                        }')
  end

  context 'when one-time orders have not been received' do
    it 'has receipt status of Awaiting Receipt' do
      expect(orders_hash['compositePoLines'][0]['receiptStatus']).to eq 'Awaiting Receipt'
    end

    it 'has a null receipt date' do
      expect(orders_hash['compositePoLines'][0]['receiptDate']).to be_nil
    end

    it 'has manually add pieces for receiving box not checked' do
      expect(orders_hash['compositePoLines'].sample['checkinItems']).to be_falsey
    end

    it 'has a billTo address' do
      expect(orders_hash['billTo']).to eq 'entry-5678'
    end

    it 'has a shipTo address' do
      expect(orders_hash['shipTo']).to eq 'entry-5678'
    end

    it 'has an instanceId' do
      expect(orders_hash['compositePoLines'][0]['instanceId']).to eq 'b13bcc4c-aa4f-5801-8a8a-22cf7b85dcc0'
    end
  end

  context 'when XINFO fields should not become tags' do
    it 'does not have a tags key' do
      expect(orders_hash).not_to have_key 'tags'
    end
  end

  context 'when Symphony fund name is used for Folio fund code' do
    it 'has the correct fund name in the field code' do
      expect(orders_hash['compositePoLines'][0]['fundDistribution'][0]['code']).to eq 'BLAWFUND'
    end

    it 'has the correct UUID in the field fundId' do
      expect(orders_hash['compositePoLines'][0]['fundDistribution'][0]['fundId']).to eq 'fund-123'
    end
  end
end
