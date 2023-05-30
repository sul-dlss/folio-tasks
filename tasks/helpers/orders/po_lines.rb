# frozen_string_literal: true

# Module to encapsulate methods used by orders rake tasks to create po lines
module PoLinesHelpers
  include FolioRequestHelper

  def add_po_line(orderlines, order_type, order_type_map, hldg_code_loc_map, funds)
    po_lines = []
    orderlines.each_value do |po_line|
      po_lines.push(po_line_hash(po_line, order_type, order_type_map, hldg_code_loc_map, funds))
    end
    po_lines
  end

  def po_line_hash(po_line_data, order_type, order_type_map, hldg_code_loc_map, funds)
    hash = {
      'orderFormat' => order_format(order_type, order_type_map),
      'checkinItems' => check_in_items?(order_type, order_type_map),
      'receiptDate' => date_format(po_line_data['DIST_DATE_RCVD']),
      'paymentStatus' => payment_status(order_type, order_type_map, po_line_data),
      'receiptStatus' => receipt_status(po_line_data['DIST_DATE_RCVD'], order_type, order_type_map),
      'selector' => po_line_data['SELECTOR'],
      'poLineDescription' => add_parts_in_set_xinfo_field(po_line_data['PARTS_IN_SET']),
      'vendorDetail' => add_vendor_detail(po_line_data['ACCOUNT']),
      'instanceId' => determine_instance_uuid(po_line_data['CKEY'], Settings.okapi.url.to_s),
      'titleOrPackage' => po_line_data['TITLE'],
      'edition' => add_edition(po_line_data['CALLNUM']),
      'acquisitionMethod' => acquisition_method(order_type, order_type_map),
      'source' => 'API',
      'cost' => add_cost(po_line_data['ORDLINE_UNIT_LIST_PRICE'], order_format(order_type, order_type_map)),
      'fundDistribution' => add_fund_data(po_line_data['fundDistribution'], po_line_data['HOLDNG_CODE'], funds)
    }
    add_locations(hash, po_line_data['HOLDNG_CODE'], hldg_code_loc_map)
    add_physical(hash, material_type(order_type, order_type_map))
    add_eresource(hash, material_type(order_type, order_type_map))
    hash.compact
  end

  def add_parts_in_set_xinfo_field(data)
    return if data.nil? || data.eql?('')

    data.to_s
  end

  def add_vendor_detail(data)
    return if data.nil?

    {
      'instructions' => '',
      'vendorAccount' => data.to_s
    }
  end

  def determine_instance_uuid(legacy_identifier, okapi_url)
    FolioUuid.new.generate(okapi_url, 'instances', legacy_identifier.prepend('a'))
  end

  def add_edition(data)
    return if data.start_with?('XX(')

    data
  end

  def add_cost(list_price, format)
    cost = {
      'currency' => 'USD'
    }
    case format
    when 'Electronic Resource'
      add_eresource_cost(cost, list_price)
    when 'P/E Mix'
      add_physical_cost(cost, list_price)
      add_eresource_cost(cost, list_price)
    else
      add_physical_cost(cost, list_price)
    end
    cost.compact
  end

  def add_physical_cost(cost, list_price)
    cost.store('listUnitPrice', dollars_to_float(list_price))
    cost.store('quantityPhysical', 1)
    cost
  end

  def add_eresource_cost(cost, list_price)
    cost.store('listUnitPriceElectronic', dollars_to_float(list_price))
    cost.store('quantityElectronic', 1)
    cost
  end

  def add_fund_data(fund_data, hldg_code, funds)
    fund_dist = []
    fund_data.each do |distribution|
      fund_dist.push(distribution_hash(distribution, hldg_code, funds))
    end
    fund_dist
  end

  def distribution_hash(distribution, hldg_code, funds)
    if hldg_code.match?(/^LAW/)
      {
        'code' => "#{distribution['FUND_NAME']}-Law",
        'fundId' => funds.fetch("#{distribution['FUND_NAME']}-Law", nil),
        'distributionType' => distribution_type(distribution['FUNDING_TYPE']),
        'value' => distribution_value(distribution)
      }
    else
      {
        'code' => "#{distribution['FUND_NAME']}-SUL",
        'fundId' => funds.fetch("#{distribution['FUND_NAME']}-SUL", nil),
        'distributionType' => distribution_type(distribution['FUNDING_TYPE']),
        'value' => distribution_value(distribution)
      }
    end
  end

  def distribution_type(funding_type)
    return 'percentage' if funding_type.match?(/0|2/) # Symphony funding type 0 and 2
    return 'amount' if funding_type.match?(/3|4/) # Symphony funding type 3 and 4
  end

  def distribution_value(distribution)
    return distribution['FUNDING_PERCENT'].to_i if distribution_type(distribution['FUNDING_TYPE']).eql?('percentage')
    return dollars_to_float(distribution['FUNDING_AMT_ENCUM']) if distribution_type(distribution['FUNDING_TYPE'])
                                                                  .eql?('amount')
  end

  def add_locations(po_line_hash, hldg_code, hldg_code_loc_map)
    locations = {
      'locationId' => hldg_code_loc_map.fetch(hldg_code, nil),
      'quantity' => 1
    }
    case po_line_hash['orderFormat']
    when 'Electronic Resource'
      locations.store('quantityElectronic', 1)
    when 'P/E Mix'
      locations.store('quantityElectronic', 1)
      locations.store('quantityPhysical', 1)
    else
      locations.store('quantityPhysical', 1) # Physical Resource and Other
    end
    po_line_hash.store('locations', [locations.compact]) # json schema expects an array
    po_line_hash
  end

  def add_eresource(po_line_hash, material_type)
    if po_line_hash['orderFormat']&.match?(/Electronic|Mix/)
      po_line_hash.store('eresource', eresource_physical_hash(material_type))
    end
    po_line_hash
  end

  def add_physical(po_line_hash, material_type)
    if po_line_hash['orderFormat']&.match?(/Physical|Mix|Other/)
      po_line_hash.store('physical', eresource_physical_hash(material_type))
    end
    po_line_hash
  end

  def eresource_physical_hash(material_type)
    {
      'createInventory' => 'None',
      'materialType' => material_type
    }
  end

  def link_po_lines_to_inventory(filedir)
    files_to_process, new_dirpath, update_error_filepath = link_po_lines_files(filedir)
    update_error_file = File.open(update_error_filepath, 'w')
    files_to_process.each do |file|
      po_number = JSON.parse(File.read(file))['poNumber']
      po_lines = orders_get_polines_po_num(po_number)['poLines']
      file_basename = File.basename(file)
      responses = []
      po_lines.each do |po_line|
        holding_id = lookup_holdings(po_line)
        updated_po_line = update_po_line_create_inventory(po_line, holding_id)
        updated_po_line_num = updated_po_line['poLineNumber']
        response = orders_storage_put_polines(updated_po_line['id'], updated_po_line)
        responses.push(response)
        puts "#{updated_po_line_num} po line successfully updated" if response == 204

        update_error_file.puts(updated_po_line_num.to_s)
      end
      File.rename(file, "#{new_dirpath}/#{file_basename}") if responses.reject { |r| /^2\d{2}/ =~ r.to_s }.empty?
    end
    update_error_file.close
  end

  def link_po_lines_files(filedir)
    dirpath = "#{Settings.json_orders}/#{filedir}"
    [Dir[File.join("#{dirpath}_orders_loaded", '*.json')], "#{dirpath}_polines_linked",
     "#{dirpath}_link_polines_errors"]
  end

  def lookup_holdings(obj)
    # locations could be nil or locationId could be when reprocessing files that had locationId updated to holdingId
    return nil if obj['locations'].nil? || obj['locations'][0]['locationId'].nil?

    instance_id = obj['instanceId']
    location_id = obj['locations'][0]['locationId']
    call_num = obj['edition']
    if call_num.nil?
      holding_no_callnum(instance_id, location_id)
    else
      hold_with_callnum = holding_with_callnum(instance_id, location_id, call_num)
      hold_with_callnum || holding_no_callnum(instance_id, location_id)
    end
  end

  def holding_no_callnum(instance_id, location_id)
    query = "instanceId==#{instance_id} and permanentLocationId==#{location_id}"
    results = @@folio_request.get_cql('/holdings-storage/holdings', CGI.escape(query).to_s)
    results['holdingsRecords'][0]['id'] if results['totalRecords'] != 0
  end

  def holding_with_callnum(instance_id, location_id, call_num)
    query = "instanceId==#{instance_id} and permanentLocationId==#{location_id} and callNumber==\"#{call_num}\""
    results = @@folio_request.get_cql('/holdings-storage/holdings', CGI.escape(query).to_s)
    results['holdingsRecords'][0]['id'] if results['totalRecords'] == 1
  end

  def update_po_line_create_inventory(po_line_hash, holding_id)
    po_line_hash.delete('edition') # callnum was temporarily stored in the edition field
    po_line_hash['eresource']['createInventory'] = 'Instance, Holding, Item' if po_line_hash['eresource']
    po_line_hash['physical']['createInventory'] = 'Instance, Holding, Item' if po_line_hash['physical']
    return po_line_hash if holding_id.nil? # no holdings to link to, keep locationId in locations field

    po_line_hash['locations'][0].delete('locationId')
    po_line_hash['locations'][0].store('holdingId', holding_id)

    po_line_hash
  end

  def orders_get_polines_po_num(po_number)
    @@folio_request.get("/orders/order-lines?query=poLineNumber==#{po_number}*")
  end

  def orders_storage_put_polines(id, obj)
    @@folio_request.put("/orders-storage/po-lines/#{id}", obj.to_json, response_code: true)
  end
end
