# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'transform SUL orders rake tasks' do
  let(:transform_sul_orders_task) { Rake.application.invoke_task 'acquisitions:transform_sul_orders' }
  let(:acq_unit_uuid) { AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil) }
  let(:order_type_map) do
    transform_sul_orders_task.send(:order_type_mapping, 'order_type_map.tsv', Uuids.material_types,
                                   AcquisitionsUuidsHelpers.acquisition_methods)
  end
  let(:hldg_code_map) do
    transform_sul_orders_task.send(:hldg_code_map, 'sym_hldg_code_location_map.tsv', Uuids.sul_locations)
  end
  let(:uuid_hashes) do
    [acq_unit_uuid, Uuids.tenant_addresses, AcquisitionsUuidsHelpers.sul_organizations, order_type_map, hldg_code_map,
     AcquisitionsUuidsHelpers.sul_funds]
  end
  let(:sul_order_yaml_dir) { Settings.yaml.sul_orders.to_s }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/acquisitions-units/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123", "name": "SUL" }] }')

    stub_request(:get, 'http://example.com/configurations/entries')
      .with(query: hash_including)
      .to_return(body: '{ "configs": [{ "id": "entry-1234", "code": "SUL_ACQUISITIONS" },
                                      { "id": "entry-1234", "code": "SUL_SERIALS" },
                                      { "id": "entry-5678", "code": "LAW_ACQUISITIONS" }]
                        }')
    stub_request(:get, 'http://example.com/organizations/organizations')
      .with(query: hash_including)
      .to_return(body: '{ "organizations": [{ "id": "org-123", "code": "VENDOR-SUL" },
                                            { "id": "org-456", "code": "MIGRATE-ERR-SUL" },
                                            { "id": "org-789", "code": "VENDOR/GBP-SUL" }]
                        }')
    stub_request(:get, 'http://example.com/finance/ledgers')
      .with(query: hash_including)
      .to_return(body: '{ "ledgers": [{ "id": "led-123", "code": "SUL" }] }')

    stub_request(:get, 'http://example.com/finance/funds')
      .with(query: hash_including)
      .to_return(body: '{ "funds": [{ "id": "fund-123", "code": "ASULFUNDA-SUL" },
                                    { "id": "fund-123", "code": "ASULFUNDB-SUL" }] }')

    stub_request(:get, 'http://example.com/material-types')
      .with(query: hash_including)
      .to_return(body: '{ "mtypes": [{ "id": "mat-123", "name": "book" },
                                     { "id": "mat-456", "name": "periodical" },
                                     { "id": "mat-789", "name": "unspecified" }]
                        }')

    stub_request(:get, 'http://example.com/orders/acquisition-methods')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionMethods": [{ "id": "acq-123", "value": "Other" },
                                                 { "id": "acq-456", "value": "Purchase" }]
                        }')

    stub_request(:get, 'http://example.com/location-units/campuses?limit=999')
      .to_return(body: '{ "loccamps": [{ "id": "camp-123", "code": "SUL" }]}')

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

  context 'when one-time orders have been received' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/222222F22.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/222222F22.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has a UUID in the id field' do
      expect(orders_hash['id']).to eq '702e48f3-2931-5c47-9767-07211e561303'
    end

    it 'has the approved box checked' do
      expect(orders_hash['approved']).to be_truthy
    end

    it 'has an approvalDate of date-time formatted string' do
      expect(orders_hash['approvalDate']).to eq '2022-04-04T00:00:00.000-08:00'
    end

    it 'has a dateOrdered of date-time formatted string' do
      expect(orders_hash['dateOrdered']).to eq '2022-04-04T00:00:00.000-08:00'
    end

    it 'puts symphony date ordered in po note field' do
      expect(orders_hash['notes']).to include 'DATE CREATED: 20220404'
    end

    it 'has an alphanumeric poNumber up to 22 characters' do
      expect(orders_hash['poNumber']).to match(/^[a-zA-Z0-9]{1,22}$/)
    end

    it 'has order type of One-Time' do
      expect(orders_hash['orderType']).to eq 'One-Time'
    end

    it 'has the UUID of the vendor' do
      expect(orders_hash['vendor']).to eq 'org-123'
    end

    it 'has an array of acq unit ids' do
      expect(orders_hash['acqUnitIds']).to include 'acq-123'
    end

    it 'has manual the box manual unchecked' do
      expect(orders_hash['manualPo']).to be_falsey
    end

    it 'has the re-encumber box unchecked' do
      expect(orders_hash['reEncumber']).to be_falsey
    end

    it 'has payment status of Awaiting Payment' do
      expect(orders_hash['compositePoLines'][0]['paymentStatus']).to eq 'Awaiting Payment'
    end

    it 'has receipt status of Fully Received' do
      expect(orders_hash['compositePoLines'][0]['receiptStatus']).to eq 'Fully Received'
    end

    it 'has a receipt date of date-time formatted string' do
      expect(orders_hash['compositePoLines'][0]['receiptDate']).to eq '2022-04-13T00:00:00.000-08:00'
    end

    it 'has receiving workflow box set to synchronized' do
      expect(orders_hash['compositePoLines'].sample['checkinItems']).to be_falsey
    end

    it 'has an instanceId' do
      expect(orders_hash['compositePoLines'][0]['instanceId']).to eq 'd8532cc3-fe98-5c70-b06f-bc3458b1a744'
    end

    it 'has a call number in the edition field' do
      expect(orders_hash['compositePoLines'][0]['edition']).to eq 'AB123 .C45 D678'
    end
  end

  context 'when one-time orders have not been received' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/444444F21.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/444444F21.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has receipt status of Awaiting Receipt' do
      expect(orders_hash['compositePoLines'][0]['receiptStatus']).to eq 'Awaiting Receipt'
    end

    it 'has a null receipt date' do
      expect(orders_hash['compositePoLines'][0]['receiptDate']).to be_nil
    end

    it 'has receiving workflow box set to synchronized' do
      expect(orders_hash['compositePoLines'].sample['checkinItems']).to be_falsey
    end

    it 'has a title in titleOrPackage' do
      expect(orders_hash['compositePoLines'].sample['titleOrPackage']).to eq 'A title'
    end

    it 'has account number in vendorAccount' do
      expect(orders_hash['compositePoLines'].sample['vendorDetail']['vendorAccount']).to eq '400958'
    end

    it 'has blank string in instructions' do
      expect(orders_hash['compositePoLines'].sample['vendorDetail']['instructions']).to eq ''
    end

    it 'puts symphony date ordered in po note field' do
      expect(orders_hash['notes']).to include 'DATE CREATED: 20200928'
    end
  end

  context 'when orders are ongoing subscriptions' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/888888F07.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/888888F07.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has isSubscription is true' do
      expect(orders_hash['ongoing']['isSubscription']).to be_truthy
    end

    it 'has renewal interval of 365 days' do
      expect(orders_hash['ongoing']['interval']).to eq 365
    end

    it 'has renewalDate of Jan 1, 2024' do
      expect(orders_hash['ongoing']['renewalDate']).to eq '2024-01-01T00:00:00.000-08:00'
    end

    it 'has payment status of Ongoing' do
      expect(orders_hash['compositePoLines'][0]['paymentStatus']).to eq 'Ongoing'
    end

    it 'has receipt status of Ongoing even though po_line has date received' do
      expect(orders_hash['compositePoLines'][0]['receiptStatus']).to eq 'Ongoing'
    end

    it 'has receiving workflow box set to independent' do
      expect(orders_hash['compositePoLines'].sample['checkinItems']).to be_truthy
    end

    it 'has a title in titleOrPackage' do
      expect(orders_hash['compositePoLines'].sample['titleOrPackage']).to eq 'A title'
    end

    it 'has a shipTo address' do
      expect(orders_hash['shipTo']).to eq 'entry-1234'
    end

    it 'has a material type of periodical' do
      expect(orders_hash['compositePoLines'].sample['physical']['materialType']).to eq 'mat-456'
    end

    it 'puts symphony date ordered in po note field' do
      expect(orders_hash['notes']).to include 'DATE CREATED: 20061018'
    end
  end

  context 'when orders are ongoing but not subscriptions' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/555555F12.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/555555F12.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has order type of ongoing' do
      expect(orders_hash['orderType']).to eq 'Ongoing'
    end

    it 'has the re-encumber box checked' do
      expect(orders_hash['reEncumber']).to be_truthy
    end

    it 'has isSubscription is false' do
      expect(orders_hash['ongoing']['isSubscription']).to be_falsey
    end

    it 'po line 1 does not have a receipt date' do
      expect(orders_hash['compositePoLines'][0]['receiptDate']).to be_falsey
    end

    it 'po line with received item has a receipt date' do
      expect(orders_hash['compositePoLines'][1]['receiptDate']).to eq '2022-04-15T00:00:00.000-08:00'
    end

    it 'has receiving workflow box set to independent' do
      expect(orders_hash['compositePoLines'].sample['checkinItems']).to be_truthy
    end

    it 'po line 1 does not have a details object with receivingNote' do
      expect(orders_hash['compositePoLines'][0]).not_to have_key 'details'
    end

    it 'po line with parts in set poLineDescription field' do
      expect(orders_hash['compositePoLines'][1]['poLineDescription']).to eq '1/1/22-12/31/22, PMT'
    end

    it 'has a material type of book' do
      expect(orders_hash['compositePoLines'].sample['physical']['materialType']).to eq 'mat-123'
    end

    it 'has a title in titleOrPackage' do
      expect(orders_hash['compositePoLines'].sample['titleOrPackage']).to eq 'A title'
    end
  end

  context 'when orders have split funding by amount' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/333333F22.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/333333F22.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }
    let(:po_line_fund_dist) { orders_hash['compositePoLines'][0]['fundDistribution'] }

    it 'has distribution type of amount' do
      expect(po_line_fund_dist[0]['distributionType']).to eq 'amount'
    end

    it 'has a value that is a number' do
      expect(po_line_fund_dist[0]['value']).to be_a Numeric
    end

    it 'has a value that is from FUNDING_AMT_ENCUM' do
      expect(po_line_fund_dist[0]['value']).to eq 0.0
    end

    it 'has the correct fund name in the field code' do
      expect(po_line_fund_dist[0]['code']).to eq 'ASULFUNDA-SUL'
    end

    it 'has the correct UUID in the field fundId' do
      expect(po_line_fund_dist[0]['fundId']).to eq 'fund-123'
    end

    it 'has receiving workflow box set to independent' do
      expect(orders_hash['compositePoLines'].sample['checkinItems']).to be_truthy
    end

    it 'does not have a poLineDescription field' do
      expect(orders_hash['compositePoLines'][0]['poLineDescription']).to be_nil
    end
  end

  context 'when orders have split funding by percentage' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/222222F22.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/222222F22.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }
    let(:po_line_fund_dist) { orders_hash['compositePoLines'][0]['fundDistribution'] }

    it 'has distribution type of percentage' do
      expect(po_line_fund_dist[0]['distributionType']).to eq 'percentage'
    end

    it 'has a value that is a number' do
      expect(po_line_fund_dist[0]['value']).to be_a Numeric
    end

    it 'has a value that is from FUNDING_PERCENT' do
      expect(po_line_fund_dist[0]['value']).to eq 50
    end

    it 'has the correct fund name in the field code' do
      expect(po_line_fund_dist[0]['code']).to eq 'ASULFUNDA-SUL'
    end

    it 'has the correct UUID in the field fundId' do
      expect(po_line_fund_dist[0]['fundId']).to eq 'fund-123'
    end
  end

  context 'when extended info notes map to FOLIO order and po line fields' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/666666F07.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/666666F07.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has order xinfo and orderline1 xinfo notes as list of notes' do
      expect(orders_hash['notes']).to be_a Array
    end

    it 'has FOLIO order note field populated with notes' do
      expect(orders_hash['notes']).to include 'NOTE: mvk payaccess 20061030'
    end

    it 'has CONTACT in the note field' do
      expect(orders_hash['notes']).to include 'CONTACT: name@example.com'
    end

    it 'has SELECTOR in the selector field' do
      expect(orders_hash['compositePoLines'][0]['selector']).to eq 'gb'
    end

    it 'has BIGDEAL or DATA xinfo note as tags' do
      expect(orders_hash['tags']['tagList']).to include 'SULBIGDEAL:Elsevier'
    end

    it 'does not have empty note fields' do
      order_id, sym_order = transform_sul_orders_task.send(:get_id_data,
                                                           YAML.load_file("#{sul_order_yaml_dir}/555555F12.yaml"))
      order = transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes)
      expect(order['notes']).not_to include 'COMMENT: '
    end

    it 'has FUND in the purchase order note field' do
      order_id, sym_order = transform_sul_orders_task.send(:get_id_data,
                                                           YAML.load_file("#{sul_order_yaml_dir}/555555F12.yaml"))
      order = transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes)
      expect(order['notes']).to include 'FUND: ASULFUND 25%; ASULFUND 12%; ASULFUND 63%'
    end

    it 'has INSTRUCT in the purchase order note field' do
      order_id, sym_order = transform_sul_orders_task.send(:get_id_data,
                                                           YAML.load_file("#{sul_order_yaml_dir}/444444F21.yaml"))
      order = transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes)
      expect(order['notes']).to include 'INSTRUCT: an instruction note'
    end
  end

  context 'when order format is physical resource' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/222222F22.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/222222F22.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has a locations object with quantityPhysical' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]['quantityPhysical']).to eq 1
    end

    it 'does not have a locations object with quantityElectronic' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]).not_to have_key 'quantityElectronic'
    end

    it 'has a locations object with locationId' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]['locationId']).to eq 'loc-123'
    end

    it 'has a cost object with listUnitPrice' do
      expect(orders_hash['compositePoLines'][0]['cost']['listUnitPrice']).to eq 1000
    end

    it 'does not have a cost object with listUnitPriceElectronic' do
      expect(orders_hash['compositePoLines'][0]['cost']).not_to have_key 'listUnitPriceElectronic'
    end

    it 'has a cost object with quantityPhysical' do
      expect(orders_hash['compositePoLines'][0]['cost']['quantityPhysical']).to eq 1
    end

    it 'does not have a cost object with quantityElectronic' do
      expect(orders_hash['compositePoLines'][0]['cost']).not_to have_key 'quantityElectronic'
    end

    it 'has a cost object with currency' do
      expect(orders_hash['compositePoLines'][0]['cost']['currency']).to eq 'USD'
    end

    it 'has a physical object' do
      expect(orders_hash['compositePoLines'][0]).to have_key 'physical'
    end

    it 'has a material type of book' do
      expect(orders_hash['compositePoLines'].sample['physical']['materialType']).to eq 'mat-123'
    end

    it 'does not have an eresource object' do
      expect(orders_hash['compositePoLines'][0]).not_to have_key 'eresource'
    end
  end

  context 'when order format is electronic resource' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/666666F07.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/666666F07.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has a locations object with quantityElectronic' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]['quantityElectronic']).to eq 1
    end

    it 'does not have a locations object with quantityPhysical' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]).not_to have_key 'quantityPhysical'
    end

    it 'has a locations object with locationId' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]['locationId']).to eq 'loc-123'
    end

    it 'has a cost object with listUnitPriceElectronic' do
      expect(orders_hash['compositePoLines'][0]['cost']['listUnitPriceElectronic']).to eq 0
    end

    it 'does not have a cost object with listUnitPrice' do
      expect(orders_hash['compositePoLines'][0]['cost']).not_to have_key 'listUnitPrice'
    end

    it 'has a cost object with quantityElectronic' do
      expect(orders_hash['compositePoLines'][0]['cost']['quantityElectronic']).to eq 1
    end

    it 'does not have a cost object with quantityPhysical' do
      expect(orders_hash['compositePoLines'][0]['cost']).not_to have_key 'quantityPhysical'
    end

    it 'has a cost object with currency' do
      expect(orders_hash['compositePoLines'][0]['cost']['currency']).to eq 'USD'
    end

    it 'has an eresource object' do
      expect(orders_hash['compositePoLines'][0]).to have_key 'eresource'
    end

    it 'has a material type of serial' do
      expect(orders_hash['compositePoLines'].sample['eresource']['materialType']).to eq 'mat-456'
    end

    it 'does not have a physical object' do
      expect(orders_hash['compositePoLines'][0]).not_to have_key 'physical'
    end

    it 'has a billTo address' do
      expect(orders_hash['billTo']).to eq 'entry-1234'
    end

    it 'has a shipTo address' do
      expect(orders_hash['shipTo']).to eq 'entry-1234'
    end
  end

  context 'when acquisition method is Shipping' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/VENDOR_GBP-SH.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/VENDOR_GBP-SH.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'removes forward slashes and hyphens from poNumber' do
      expect(orders_hash['poNumber']).to eq 'VENDORGBPSH'
    end

    it 'has an alphanumeric poNumber up to 22 characters' do
      expect(orders_hash['poNumber']).to match(/^[a-zA-Z0-9]{1,22}$/)
    end

    it 'has orderFormat Other' do
      expect(orders_hash['compositePoLines'].sample['orderFormat']).to eq 'Other'
    end

    it 'has a locations object with quantityPhysical' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]['quantityPhysical']).to eq 1
    end

    it 'has a cost object with listUnitPrice' do
      expect(orders_hash['compositePoLines'][0]['cost']['listUnitPrice']).to eq 0
    end

    it 'has a cost object with quantityPhysical' do
      expect(orders_hash['compositePoLines'][0]['cost']['quantityPhysical']).to eq 1
    end

    it 'has a cost object with currency' do
      expect(orders_hash['compositePoLines'][0]['cost']['currency']).to eq 'USD'
    end

    it 'has a physical object with materialType for unspecified' do
      expect(orders_hash['compositePoLines'][0]['physical']['materialType']).to eq 'mat-789'
    end
  end

  context 'when order format is P/E Mix' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/777777F02.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/777777F02.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has orderFormat P/E Mix' do
      expect(orders_hash['compositePoLines'].sample['orderFormat']).to eq 'P/E Mix'
    end

    it 'has a locations object with quantityElectronic' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]['quantityElectronic']).to eq 1
    end

    it 'has a locations object with quantityPhysical' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]['quantityPhysical']).to eq 1
    end

    it 'has a locations object with locationId' do
      expect(orders_hash['compositePoLines'][0]['locations'][0]['locationId']).to eq 'loc-123'
    end

    it 'has a cost object with listUnitPrice' do
      expect(orders_hash['compositePoLines'][0]['cost']['listUnitPrice']).to eq 0
    end

    it 'has a cost object with quantityPhysical' do
      expect(orders_hash['compositePoLines'][0]['cost']['quantityPhysical']).to eq 1
    end

    it 'has a cost object with listUnitPriceElectronic' do
      expect(orders_hash['compositePoLines'][0]['cost']['listUnitPriceElectronic']).to eq 0
    end

    it 'has a cost object with quantityElectronic' do
      expect(orders_hash['compositePoLines'][0]['cost']['quantityElectronic']).to eq 1
    end

    it 'has a cost object with currency' do
      expect(orders_hash['compositePoLines'][0]['cost']['currency']).to eq 'USD'
    end

    it 'has a physical material type of book' do
      expect(orders_hash['compositePoLines'].sample['physical']['materialType']).to eq 'mat-123'
    end

    it 'has an eresource material type of book' do
      expect(orders_hash['compositePoLines'].sample['eresource']['materialType']).to eq 'mat-123'
    end
  end

  context 'when orderline should not link to an instance holdings record' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/666666F07.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/666666F07.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'does not have a call number in the edition field' do
      expect(orders_hash['compositePoLines'][0]).not_to have_key 'edition'
    end
  end

  context 'when vendor does not exist in Folio' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/555555F12.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/555555F12.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has the correct vendor UUID' do
      expect(orders_hash['vendor']).to eq 'org-456'
    end
  end

  context 'when acquisition method does not exist in Folio' do
    let(:order_id) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/1ABC0000.yaml")).shift
    end
    let(:sym_order) do
      transform_sul_orders_task.send(:get_id_data, YAML.load_file("#{sul_order_yaml_dir}/1ABC0000.yaml")).pop
    end
    let(:orders_hash) { transform_sul_orders_task.send(:orders_hash, order_id, sym_order, uuid_hashes) }

    it 'has the acquisitions method UUID for Other' do
      expect(orders_hash['compositePoLines'].sample['acquisitionMethod']).to eq 'acq-123'
    end
  end
end
