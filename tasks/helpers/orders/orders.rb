# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate methods used by orders rake tasks
module OrdersTaskHelpers
  include FolioRequestHelper

  def transform_sul_orders
    sul_uuids = uuid_hashes('SUL')
    Dir.each_child(Settings.yaml.sul_orders.to_s) do |file|
      order_id, sym_order = get_id_data(YAML.load_file("#{Settings.yaml.sul_orders}/#{file}"))
      folio_composite_orders = orders_hash(order_id, sym_order, sul_uuids)
      File.open("#{Settings.json_orders}/sul/#{file.tr('.yaml', '.json')}", 'w') do |f|
        f.puts folio_composite_orders.to_json
      end
    end
  end

  def transform_law_orders
    law_uuids = uuid_hashes('Law')
    Dir.each_child(Settings.yaml.law_orders.to_s) do |file|
      order_id, sym_order = get_id_data(YAML.load_file("#{Settings.yaml.law_orders}/#{file}"))
      folio_composite_orders = orders_hash(order_id, sym_order, law_uuids)
      File.open("#{Settings.json_orders}/law/#{file.tr('.yaml', '.json')}", 'w') do |f|
        f.puts folio_composite_orders.to_json
      end
    end
  end

  def acq_unit_uuid(lib)
    acq_units.fetch(lib, nil)
  end

  def order_type_map
    order_type_mapping('order_type_map.tsv', material_types, acquisition_methods)
  end

  def hldg_code_loc_map(lib)
    uuids = lib == 'SUL' ? sul_locations : law_locations
    hldg_code_map('sym_hldg_code_location_map.tsv', uuids)
  end

  def uuid_hashes(lib)
    orgs = lib == 'SUL' ? sul_organizations : law_organizations
    funds = lib == 'SUL' ? sul_funds : law_funds
    [acq_unit_uuid(lib), tenant_addresses, orgs, order_type_map, hldg_code_loc_map(lib), funds]
  end

  def get_id_data(yaml_hash)
    [yaml_hash.keys.first, yaml_hash.values.first]
  end

  def orders_hash(order_id, sym_order, uuid_hashes)
    acq_unit_uuid, addresses, organizations, order_type_map, hldg_code_loc_map, funds = uuid_hashes
    composite_orders = {
      'id' => determine_order_uuid(cleanup_po_num(order_id), Settings.okapi.url.to_s),
      'approved' => true,
      'approvalDate' => date_format(sym_order['ORD_DATE_CREATED']),
      'dateOrdered' => date_format(sym_order['ORD_DATE_CREATED']),
      'poNumber' => cleanup_po_num(order_id),
      'orderType' => order_type(sym_order['ORDER_TYPE'], order_type_map),
      'vendor' => vendor_uuid(sym_order['VENDOR_ID'], sym_order['LIBRARY'], organizations),
      'manualPo' => false,
      'reEncumber' => reencumber?(order_type(sym_order['ORDER_TYPE'], order_type_map)),
      'acqUnitIds' => [acq_unit_uuid],
      'workflowStatus' => 'Open'
    }
    add_composite_po_lines(composite_orders, sym_order, order_type_map, hldg_code_loc_map, funds)
    add_bill_to(composite_orders, sym_order['LIBRARY'], addresses)
    add_ship_to(composite_orders, sym_order['LIBRARY'], sym_order['compositePoLines'].values[0]['BIB_ENTRY'], addresses)
    add_ongoing(composite_orders, sym_order['ORDER_TYPE'], order_type_map)
    add_notes(composite_orders, sym_order)
    add_tags(composite_orders, sym_order)
    composite_orders.compact
  end

  def determine_order_uuid(legacy_identifier, okapi_url)
    FolioUuid.new.generate(okapi_url, 'orders', legacy_identifier)
  end

  def vendor_uuid(vendor_id, order_library, organizations)
    case order_library
    when 'LAW'
      default_vendor = organizations.fetch('MIGRATE-ERR-Law', nil)
    when 'SUL'
      default_vendor = organizations.fetch('MIGRATE-ERR-SUL', nil)
    end
    organizations.fetch(folio_org_format(vendor_id, order_library), default_vendor)
  end

  def add_composite_po_lines(composite_orders, sym_order, order_type_map, hldg_code_loc_map, funds)
    composite_orders.store('compositePoLines',
                           add_po_line(sym_order['compositePoLines'], sym_order['ORDER_TYPE'], order_type_map,
                                       hldg_code_loc_map, funds))
  end

  def add_bill_to(composite_orders, library, addresses)
    return composite_orders if bill_to_uuid(library, addresses).nil?

    composite_orders.store('billTo', bill_to_uuid(library, addresses))
  end

  def add_ship_to(composite_orders, library, bib_entry, addresses)
    return composite_orders if ship_to_uuid(library, bib_entry, addresses).nil?

    composite_orders.store('shipTo', ship_to_uuid(library, bib_entry, addresses))
  end

  def address_codes
    {
      'SUL' => 'SUL_ACQUISITIONS',
      'AFRACQ' => 'SUL_ACQUISITIONS',
      'DIGACQ' => 'SUL_ACQUISITIONS',
      'GEACQ' => 'SUL_ACQUISITIONS',
      'GOV' => 'SUL_ACQUISITIONS',
      'MEACQ' => 'SUL_ACQUISITIONS',
      'ACQ' => 'SUL_ACQUISITIONS',
      'SER' => 'SUL_SERIALS',
      'MESER' => 'SUL_SERIALS',
      'EALACQ' => 'SUL_EAL',
      'MUSACQ' => 'SUL_MUSIC',
      'LAW' => 'LAW_LIBRARY_ACQUISITIONS'
    }
  end

  def default_shipto(addresses)
    addresses.fetch('SUL_ACQUISITIONS', nil)
  end

  def bill_to_uuid(library, addresses)
    code = address_codes.fetch(library)
    addresses.fetch(code, nil)
  end

  def ship_to_uuid(library, bib_entry, addresses)
    if library.eql?('LAW')
      addresses.fetch(address_codes.fetch(library), nil)
    else
      addresses.fetch(address_codes.fetch(bib_entry, nil), default_shipto(addresses))
    end
  end

  def add_ongoing(composite_orders, order_type, order_type_map)
    return composite_orders if order_type(order_type, order_type_map).eql?('One-Time')

    composite_orders.store('ongoing', ongoing_hash(order_type, order_type_map))
  end

  def ongoing_hash(sym_order_type, order_type_map)
    if subscription?(sym_order_type, order_type_map)
      {
        'isSubscription' => true
      }
    else
      {
        'isSubscription' => false
      }
    end
  end

  def add_notes(composite_orders, sym_order)
    notes = cleanup_empty(sym_order['notes']) || []
    notes.push("DATE CREATED: #{sym_order['ORD_DATE_CREATED']}")
    composite_orders.store('notes', notes)
  end

  def add_tags(composite_orders, sym_order)
    # LAW doesn't use tags/has bad data if field is populated
    return composite_orders if sym_order['LIBRARY'].eql?('LAW')

    composite_orders.store('tags', cleanup_empty(sym_order['tags']))
  end

  def reencumber?(order_type)
    return true if order_type == 'Ongoing'

    false
  end

  def collapse_notes(notes_hash)
    new_arry = []
    notes_hash.each do |k, v|
      new_val = "#{k}: #{v.reject(&:empty?).join(", #{k}: ")}"
      new_arry.push(new_val)
    end
    new_arry
  end

  def cleanup_po_num(order_id)
    # json schema expects poNumber match(/^[a-zA-Z0-9]{1,22}$/)
    order_id.gsub(%r{[/_-]}, '')
  end

  def cleanup_empty(xinfo_fields)
    return nil if xinfo_fields.nil?

    xinfo_fields.delete_if { |field| field.match?(/^[A-Z]+:\s$/) }
  end

  def date_format(date)
    return "#{date[0..3]}-#{date[4..5]}-#{date[6..7]}T00:00:00.000-08:00" unless date.eql?('0')
  end

  def dollars_to_float(dollars)
    dollars.scan(/[.0-9]/).join.to_f
  end

  def folio_org_format(vendor, library)
    library = library.capitalize if library.eql?('LAW')
    "#{vendor}-#{library}"
  end

  def orders_post(obj)
    @@folio_request.post('/orders/composite-orders', obj.to_json)
  end

  def orders_put(id, obj)
    @@folio_request.put("/orders/composite-orders/#{id}", obj.to_json)
  end

  def orders_storage_put_po(id, obj)
    @@folio_request.put("/orders-storage/purchase-orders/#{id}", obj.to_json)
  end

  def orders_delete(id)
    @@folio_request.delete("/orders/composite-orders/#{id}")
  end
end
