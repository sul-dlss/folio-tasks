# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate methods used by orders rake tasks
module OrdersTaskHelpers
  include FolioRequestHelper

  def get_id_data(yaml_hash)
    [yaml_hash.keys.first, yaml_hash.values.first]
  end

  def orders_hash(order_id, sym_order, acq_unit_uuid, uuid_hashes)
    addresses, organizations, order_type_map, hldg_code_loc_map, funds = uuid_hashes
    composite_orders = {
      'approved' => true,
      'approvalDate' => date_format(sym_order['ORD_DATE_CREATED']),
      'dateOrdered' => date_format(sym_order['ORD_DATE_CREATED']),
      'poNumber' => cleanup_po_num(order_id),
      'orderType' => order_type(sym_order['ORDER_TYPE'], order_type_map),
      'vendor' => organizations.fetch(folio_org_format(sym_order['VENDOR_ID'], sym_order['LIBRARY'])),
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
      'ACQ' => 'SUL_ACQUISITIONS',
      'SER' => 'SUL_SERIALS',
      'EAL' => 'SUL_EAL',
      'MUS' => 'SUL_MUSIC',
      'LAW' => 'LAW_LIBRARY_ACQUISITIONS'
    }
  end

  def bill_to_uuid(library, addresses)
    code = address_codes.fetch(library)
    addresses.fetch(code, nil)
  end

  def ship_to_uuid(library, bib_entry, addresses)
    if library.eql?('LAW')
      addresses.fetch(address_codes.fetch(library), nil)
    else
      addresses.fetch(address_codes.fetch(bib_entry, nil), nil)
    end
  end

  def add_ongoing(composite_orders, order_type, order_type_map)
    return composite_orders if order_type(order_type, order_type_map).eql?('One-Time')

    composite_orders.store('ongoing', ongoing_hash(order_type, order_type_map))
  end

  def ongoing_hash(sym_order_type, order_type_map)
    if subscription?(sym_order_type, order_type_map)
      {
        'interval' => 365,
        'isSubscription' => true,
        'renewalDate' => '2023-01-01'
      }
    else
      {
        'isSubscription' => false
      }
    end
  end

  def add_notes(composite_orders, sym_order)
    composite_orders.store('notes', cleanup_empty(sym_order['notes']))
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
    return "#{date[0..3]}-#{date[4..5]}-#{date[6..7]}" unless date.eql?('0')
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
end
