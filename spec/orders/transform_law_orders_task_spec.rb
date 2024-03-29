# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'transform LAW orders rake tasks' do
  let(:transform_law_orders_task) { Rake.application.invoke_task 'orders:transform_law_orders' }
  let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('Law', nil) }
  let(:order_type_map) do
    transform_law_orders_task.send(:order_type_mapping, 'order_type_map.tsv', Uuids.material_types,
                                   AcquisitionsUuidsHelpers.acquisition_methods)
  end
  let(:hldg_code_map) do
    transform_law_orders_task.send(:hldg_code_map, 'sym_hldg_code_location_map.tsv', Uuids.law_locations)
  end
  let(:uuid_hashes) do
    [acq_unit_uuid, Uuids.tenant_addresses, AcquisitionsUuidsHelpers.law_organizations, order_type_map, hldg_code_map,
     AcquisitionsUuidsHelpers.law_funds]
  end
  let(:law_order_yaml_dir) { Settings.yaml.law_orders.to_s }
  let(:order_id) do
    transform_law_orders_task.send(:get_id_data, YAML.load_file("#{law_order_yaml_dir}/56789L02.yaml")).shift
  end
  let(:sym_order) do
    transform_law_orders_task.send(:get_id_data, YAML.load_file("#{law_order_yaml_dir}/56789L02.yaml")).pop
  end
  let(:orders_hash) { transform_law_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/acquisitions-units/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123", "name": "Law" }] }')

    stub_request(:get, 'http://example.com/configurations/entries')
      .with(query: hash_including)
      .to_return(body: '{ "configs": [{ "id": "entry-5678", "code": "LAW_LIBRARY_ACQUISITIONS" }] }')

    stub_request(:get, 'http://example.com/organizations/organizations')
      .with(query: hash_including)
      .to_return(body: '{ "organizations": [{ "id": "org-123", "code": "PCARD-Law" },
                                            { "id": "org-456", "code": "MIGRATE-ERR-Law" }]
                        }')
    stub_request(:get, 'http://example.com/finance/ledgers')
      .with(query: hash_including)
      .to_return(body: '{ "ledgers": [{ "id": "led-123", "code": "LAW" }] }')

    stub_request(:get, 'http://example.com/finance/funds')
      .with(query: hash_including)
      .to_return(body: '{ "funds": [{ "id": "fund-123", "code": "ALAWFUND-Law" },
                                    { "id": "fund-123", "code": "BLAWFUND-Law" },
                                    { "id": "fund_err-123", "code": "MIGRATE-ERR-Law" }] }')

    stub_request(:get, 'http://example.com/material-types')
      .with(query: hash_including)
      .to_return(body: '{ "mtypes": [{ "id": "mat-123", "name": "book" },
                                     { "id": "mat-456", "name": "serial" }]
                        }')

    stub_request(:get, 'http://example.com/orders/acquisition-methods')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionMethods": [{ "id": "acq-123", "value": "Other" },
                                                 { "id": "acq-123", "value": "Gift" },
                                                 { "id": "acq-456", "value": "Purchase" }]
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

    it 'has receiving workflow box set to synchronized' do
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

    it 'has a call number in the edition field' do
      expect(orders_hash['compositePoLines'][0]['edition']).to eq 'VROOMAN COLLECTION F'
    end

    it 'has a cost object with listUnitPrice' do
      expect(orders_hash['compositePoLines'][0]['cost']['listUnitPrice']).to eq 35.00
    end

    it 'does not have the Symphony orderline unit list price in po line description' do
      expect(orders_hash['compositePoLines'][0]).not_to have_key 'description'
    end
  end

  context 'when XINFO fields should not become tags' do
    it 'does not have a tags key' do
      expect(orders_hash).not_to have_key 'tags'
    end
  end

  context 'when Symphony fund name is used for Folio fund code' do
    it 'has the correct fund name in the field code' do
      expect(orders_hash['compositePoLines'][0]['fundDistribution'][0]['code']).to eq 'BLAWFUND-Law'
    end

    it 'has the correct UUID in the field fundId' do
      expect(orders_hash['compositePoLines'][0]['fundDistribution'][0]['fundId']).to eq 'fund-123'
    end
  end

  context 'when vendor does not exist in Folio' do
    it 'has the correct vendor UUID' do
      expect(orders_hash['vendor']).to eq 'org-456'
    end
  end

  context 'when acquisition method exists in Folio' do
    it 'has the correct acquisitions method UUID' do
      expect(orders_hash['compositePoLines'].sample['acquisitionMethod']).to eq 'acq-456'
    end
  end

  context 'when one-time orders have been paid' do
    it 'has a payment status of Fully Paid' do
      expect(orders_hash['compositePoLines'][0]['paymentStatus']).to eq 'Fully Paid'
    end
  end

  context 'when order is a gift' do
    let(:order_id) do
      transform_law_orders_task.send(:get_id_data, YAML.load_file("#{law_order_yaml_dir}/4321L04.yaml")).shift
    end
    let(:sym_order) do
      transform_law_orders_task.send(:get_id_data, YAML.load_file("#{law_order_yaml_dir}/4321L04.yaml")).pop
    end
    let(:orders_hash) { transform_law_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has payment status Payment Not Required' do
      expect(orders_hash['compositePoLines'][0]['paymentStatus']).to eq 'Payment Not Required'
    end
  end

  context 'when fund does not exist in Folio' do
    let(:order_id) do
      transform_law_orders_task.send(:get_id_data, YAML.load_file("#{law_order_yaml_dir}/4321L04.yaml")).shift
    end
    let(:sym_order) do
      transform_law_orders_task.send(:get_id_data, YAML.load_file("#{law_order_yaml_dir}/4321L04.yaml")).pop
    end
    let(:orders_hash) { transform_law_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has the correct fund name in the field code' do
      expect(orders_hash['compositePoLines'][0]['fundDistribution'][0]['code']).to eq 'LAWNOFUND-Law'
    end

    it 'has the error fund UUID in the field fundId' do
      expect(orders_hash['compositePoLines'][0]['fundDistribution'][0]['fundId']).to eq 'fund_err-123'
    end
  end
end
