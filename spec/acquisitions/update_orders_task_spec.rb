# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'update orders' do
  let(:link_po_lines_to_inventory) { Rake.application.invoke_task('acquisitions:link_po_lines_to_inventory[sul]') }
  let(:po_lines) { link_po_lines_to_inventory.send(:orders_get_polines_po_num, '') }
  let(:po_line) { po_lines['poLines'][0] }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/orders/order-lines')
      .with(query: hash_including)
      .to_return(body: '{ "poLines": [{ "id": "abc-123",
                                        "poLineNumber": "TEST-1",
                                        "instanceId": "ins-123",
                                        "edition": "AB123 .C45 D678",
                                        "locations": [{
                                            "locationId": "loc-123",
                                            "quantity": 1,
                                            "quantityElectronic": 1,
                                            "quantityPhysical": 1
                                        }],
                                        "physical": {
                                          "createInventory": "None",
                                          "materialType": "mat-789"
                                        },
                                        "eresource": {
                                          "createInventory": "None",
                                          "materialType": "mat-123"
                                        }}]
                        }')

    stub_request(:get, 'http://example.com/holdings-storage/holdings')
      .with(query: hash_including)
      .to_return(body: '{ "holdingsRecords": [{ "id": "abc-123" }],
                          "totalRecords": 1
                        }')

    stub_request(:put, 'http://example.com/orders-storage/po-lines/abc-123')
  end

  context 'when po line does not have a call number' do
    before do
      po_line.delete('edition')
      po_line.delete('eresource')
    end

    let(:holding_id) { link_po_lines_to_inventory.send(:lookup_holdings, po_line) }
    let(:updated_po_line) { link_po_lines_to_inventory.send(:update_po_line_create_inventory, po_line, holding_id) }

    it 'does not query holdings-storage using nil call number' do
      expect(holding_id).not_to have_requested(:get, 'http://example.com/holdings-storage/holdings?query=instanceId==ins-123%20and%20permanentLocationId==loc-123%20and%20callNumber==%22%22')
    end

    it 'removes the locationId' do
      expect(updated_po_line['locations'][0]).not_to have_key 'locationId'
    end

    it 'adds the holdingId' do
      expect(updated_po_line['locations'][0]['holdingId']).to eq 'abc-123'
    end

    it 'updates createInventory' do
      expect(updated_po_line['physical']['createInventory']).to eq 'Instance, Holding, Item'
    end
  end

  context 'when po line does not have a location' do
    before do
      po_line.delete('locations')
      po_line.delete('edition')
      po_line.delete('eresource')
    end

    let(:holding_id) { link_po_lines_to_inventory.send(:lookup_holdings, po_line) }
    let(:updated_po_line) { link_po_lines_to_inventory.send(:update_po_line_create_inventory, po_line, holding_id) }

    it 'does not query holdings-storage' do
      expect(holding_id).not_to have_requested(:get, 'http://example.com/holdings-storage/holdings')
    end

    it 'updates createInventory for physical' do
      expect(updated_po_line['physical']['createInventory']).to eq 'Instance, Holding, Item'
    end
  end

  context 'when po line is orderFormat P/E Mix' do
    let(:holding_id) { link_po_lines_to_inventory.send(:lookup_holdings, po_line) }
    let(:updated_po_line) { link_po_lines_to_inventory.send(:update_po_line_create_inventory, po_line, holding_id) }

    it 'queries holdings-storage using instanceId, locationId, and call number from po line' do
      expect(holding_id).to have_requested(:get, 'http://example.com/holdings-storage/holdings?query=instanceId==ins-123%20and%20permanentLocationId==loc-123%20and%20callNumber==%22AB123%20.C45%20D678%22').once
    end

    it 'removes the edition field' do
      expect(updated_po_line).not_to have_key 'edition'
    end

    it 'removes the locationId' do
      expect(updated_po_line['locations'][0]).not_to have_key 'locationId'
    end

    it 'adds the holdingId' do
      expect(updated_po_line['locations'][0]['holdingId']).to eq 'abc-123'
    end

    it 'updates createInventory for physical' do
      expect(updated_po_line['physical']['createInventory']).to eq 'Instance, Holding, Item'
    end

    it 'keeps the physical materialType field' do
      expect(updated_po_line['physical']['materialType']).to eq 'mat-789'
    end

    it 'updates createInventory for eresource' do
      expect(updated_po_line['eresource']['createInventory']).to eq 'Instance, Holding, Item'
    end

    it 'keeps the eresource materialType field' do
      expect(updated_po_line['eresource']['materialType']).to eq 'mat-123'
    end
  end

  context 'when po line has no holdings to link to' do
    before do
      stub_request(:get, 'http://example.com/holdings-storage/holdings')
        .with(query: hash_including)
        .to_return(body: '{ "holdingsRecords": [], "totalRecords": 0 }')
    end

    let(:holding_id) { link_po_lines_to_inventory.send(:lookup_holdings, po_line) }
    let(:updated_po_line) { link_po_lines_to_inventory.send(:update_po_line_create_inventory, po_line, holding_id) }

    it 'queries holdings-storage using instanceId, locationId, and call number from po line' do
      expect(holding_id).to have_requested(:get, 'http://example.com/holdings-storage/holdings?query=instanceId==ins-123%20and%20permanentLocationId==loc-123%20and%20callNumber==%22AB123%20.C45%20D678%22').once
    end

    it 'queries holdings-storage using instanceId and locationId from po line' do
      expect(holding_id).to have_requested(:get, 'http://example.com/holdings-storage/holdings?query=instanceId==ins-123%20and%20permanentLocationId==loc-123').at_least_once
    end

    it 'removes the edition field' do
      expect(updated_po_line).not_to have_key 'edition'
    end

    it 'keeps the locationId field' do
      expect(updated_po_line['locations'][0]['locationId']).to eq 'loc-123'
    end

    it 'does not have a holdingId field' do
      expect(updated_po_line['locations'][0]).not_to have_key 'holdingId'
    end

    it 'updates createInventory for physical' do
      expect(updated_po_line['physical']['createInventory']).to eq 'Instance, Holding, Item'
    end

    it 'keeps the physical materialType field' do
      expect(updated_po_line['physical']['materialType']).to eq 'mat-789'
    end

    it 'updates createInventory for eresource' do
      expect(updated_po_line['eresource']['createInventory']).to eq 'Instance, Holding, Item'
    end

    it 'keeps the eresource materialType field' do
      expect(updated_po_line['eresource']['materialType']).to eq 'mat-123'
    end
  end
end
