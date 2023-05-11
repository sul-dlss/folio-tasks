# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load orders' do
  let(:load_orders_task) { Rake.application.invoke_task('acquisitions:load_orders[sul]') }
  let(:load_orders_files) { load_orders_task.send(:order_load_files, 'sul') }
  let(:fixture_data) { load_orders_task.send(:purchase_order_and_po_lines, "#{Settings.json}/orders/1ABC0000.json") }
  let(:orders_post) { load_orders_task.send(:orders_post, fixture_data) }
  let(:po) { load_orders_task.send(:purchase_order, fixture_data) }
  let(:po_put) { load_orders_task.send(:orders_storage_put_po, po['id'], po) }
  let(:post_status) { { status: 201 } }
  let(:put_status) { { status: 204 } }

  let(:link_po_lines_to_inventory) { Rake.application.invoke_task('acquisitions:link_po_lines_to_inventory[sul]') }
  let(:link_po_lines_files) { link_po_lines_to_inventory.send(:link_po_lines_files, 'sul') }
  let(:po_lines) { link_po_lines_to_inventory.send(:orders_get_polines_po_num, '') }
  let(:po_line) { po_lines['poLines'][0] }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/orders/composite-orders')
      .to_return(post_status)

    stub_request(:put, %r{.*purchase-orders/.*})
      .to_return(put_status)

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
      .to_return(status: 201)
  end

  after(:all) do
    move_files("#{Settings.json_orders}/sul_polines_linked", "#{Settings.json_orders}/sul")
  end

  context 'when order successfully loads' do
    after do
      reset_files(load_orders_files, link_po_lines_files)
    end

    it 'moves the files to the loaded directory' do
      new_dirpath = load_orders_files[1]
      files_loaded = Dir[File.join(new_dirpath, '*.json')]
      expect(files_loaded).to include "#{new_dirpath}/1ABC0000.json"
    end

    it 'updates the purchase order at the orders-storage endpoint' do
      expect(po_put).to have_requested(:put, 'http://example.com/orders-storage/purchase-orders/6517dbba-54ef-5d0e-9d9d-c96cca2330dc').at_least_once
    end
  end

  context 'when order loads but update is unsuccessful' do
    after do
      reset_files(load_orders_files, link_po_lines_files)
    end

    let(:put_status) do
      {
        status: 400
      }
    end

    it 'writes to update error file if po fails to update', skip: 'passes when run in context' do
      update_error_file = File.open(load_orders_files[3])
      expect(File.size(update_error_file)).to be > 0
    end
  end

  context 'when order does not succesfully load' do
    after do
      reset_files(load_orders_files, link_po_lines_files)
    end

    let(:post_status) do
      {
        status: 400
      }
    end

    it 'does not move the file to the loaded directory' do
      new_dirpath = load_orders_files[1]
      files_loaded = Dir[File.join(new_dirpath, '*.json')]
      expect(files_loaded).not_to include "#{new_dirpath}/1ABC0000.json"
    end

    it 'writes to load error file if po did not load successfully', skip: 'passes when run in context' do
      load_error_file = File.open(load_orders_files[2])
      expect(File.size(load_error_file)).to be > 0
    end
  end

  context 'when po line successfully updates' do
    after do
      reset_files(load_orders_files, link_po_lines_files)
    end

    it 'moves the file to the po lines linked directory' do
      new_dirpath = link_po_lines_files[1]
      files_loaded = Dir[File.join(new_dirpath, '*.json')]
      expect(files_loaded).to include "#{new_dirpath}/1ABC0000.json"
    end
  end

  context 'when po line does not have a call number' do
    before do
      po_line.delete('edition')
      po_line.delete('eresource')
    end

    after do
      reset_files(load_orders_files, link_po_lines_files)
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

    after do
      reset_files(load_orders_files, link_po_lines_files)
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
    after do
      reset_files(load_orders_files, link_po_lines_files)
    end

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

    after do
      reset_files(load_orders_files, link_po_lines_files)
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

def reset_files(load_orders_files, link_po_lines_files)
  # load_orders_files = [[list of json files in json_orders/sul], json_orders/sul_orders_loaded,
  #                       file handle json_orders/sul_load_errors, file handle json_orders/sul_po_update_errors]
  # link_po_lines_files = [[list of json files in json_orders/sul_orders_loaded], json_orders/sul_po_lines_linked,
  #                         file handle json_orders/sul_link_polines_errors]
  orig_dirpath = "#{Settings.json_orders}/sul"
  loaded_dirpath = "#{Settings.json_orders}/sul_orders_loaded"
  endprocess_dirpath = "#{Settings.json_orders}/sul_po_lines_linked"

  # after 'order successfully loads' load_orders_files[0] is empty
  # after 'order loads but update is unsuccessful' load_orders_files[0] is empty
  if load_orders_files[0].empty?
    move_files(loaded_dirpath, orig_dirpath)
  # after 'order does not succesfully load' load_orders_files[0] is NOT empty (but link_po_lines_files[0] is empty)
  elsif link_po_lines_files[0].empty?
    move_files(orig_dirpath, loaded_dirpath)
  # after 'po line successfully updates' load_orders_files[0] and link_po_lines_files[0] is empty
  else
    move_files(endprocess_dirpath, orig_dirpath)
  end

  # empty error files
  File.truncate(load_orders_files[3], 0)
  File.truncate(load_orders_files[2], 0)
  File.truncate(link_po_lines_files[2], 0)
end

def move_files(dirpath, new_dirpath)
  files = Dir[File.join(dirpath, '*.json')]
  files.each do |file|
    File.rename(file, "#{new_dirpath}/#{File.basename(file)}")
  end
end