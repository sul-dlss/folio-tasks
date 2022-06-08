# frozen_string_literal: true

# Module to encapsulate methods used by orders rake tasks to create po lines
# rubocop: disable Metrics/ModuleLength
module PoLinesHelpers
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
      'paymentStatus' => payment_status(order_type, order_type_map),
      'receiptStatus' => receipt_status(po_line_data['DIST_DATE_RCVD'], order_type, order_type_map),
      'selector' => po_line_data['SELECTOR'],
      'poLineDescription' => add_fund_xinfo_field(po_line_data['FUND']),
      'instanceId' => determine_uuid(po_line_data['CKEY'], Settings.okapi.url.to_s),
      'titleOrPackage' => po_line_data['TITLE'],
      'acquisitionMethod' => acquisition_method(order_type, order_type_map),
      'source' => 'API',
      'cost' => add_cost(po_line_data['ORDLINE_UNIT_LIST_PRICE'], order_format(order_type, order_type_map)),
      'fundDistribution' => add_fund_data(po_line_data['fundDistribution'], po_line_data['HOLDNG_CODE'], funds)
    }
    add_locations(hash, po_line_data['HOLDNG_CODE'], hldg_code_loc_map)
    add_physical(hash, material_type(order_type, order_type_map))
    add_eresource(hash, material_type(order_type, order_type_map))
    add_receiving_note(hash, po_line_data['PARTS_IN_SET'])
    hash.compact
  end

  def add_fund_xinfo_field(data)
    return if data.nil?

    "FUND: #{data}"
  end

  def determine_uuid(legacy_identifier, okapi_url)
    FolioUuid.new.generate(okapi_url, 'instances', legacy_identifier.prepend('a'))
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
    return po_line_hash if po_line_hash['orderFormat'].eql?('Other')

    locations = {
      'locationId' => hldg_code_loc_map.fetch(hldg_code, nil),
      'quantity' => 1
    }
    locations.store('quantityElectronic', 1) if po_line_hash['orderFormat']&.match?(/Electronic|Mix/)
    locations.store('quantityPhysical', 1) if po_line_hash['orderFormat']&.match?(/Physical|Mix/)
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
    if po_line_hash['orderFormat']&.match?(/Physical|Mix/)
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

  def add_receiving_note(po_line_hash, part_in_set)
    return po_line_hash if part_in_set.empty?

    po_line_hash.store('details', receiving_note(part_in_set))
    po_line_hash
  end

  def receiving_note(part_in_set)
    {
      'receivingNote' => part_in_set
    }
  end
end
# rubocop: enable Metrics/ModuleLength
