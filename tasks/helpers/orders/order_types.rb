# frozen_string_literal: true

# Module to encapsulate order type methods used by orders rake tasks
module OrderTypeHelpers
  def order_type_csv(file)
    CSV.parse(File.open("#{Settings.tsv_orders}/#{file}"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def order_type_mapping(file, material_type_map)
    map = {}
    order_type_csv(file).each do |row|
      map[row['Symph_order_type']] = row.to_h
    end
    map.each_value do |obj|
      obj['materialType'] = material_type_uuid(obj['materialType'], material_type_map)
    end
    map
  end

  def order_type(field, map)
    map.dig(field, 'orderType')
  end

  def acquisition_method(field, map)
    # this needs to return the UUID for Lotus
    # see https://github.com/sul-dlss/folio_api_client/issues/102
    map.dig(field, 'acquisitionMethod')
  end

  def order_format(field, map)
    map.dig(field, 'orderFormat')
  end

  def material_type(field, map)
    map.dig(field, 'materialType')
  end

  def material_type_uuid(name, material_type_map)
    material_type_map.fetch(name, nil)
  end

  def payment_status(field, map)
    return 'Awaiting Payment' if order_type(field, map).eql?('One-Time')

    'Ongoing'
  end

  def receipt_status(receipt_date, field, map)
    if order_type(field, map).eql?('One-Time')
      return 'Fully Received' unless receipt_date.eql?('0')

      'Awaiting Receipt'
    else
      'Ongoing'
    end
  end

  def subscription?(field, map)
    map.dig(field, 'isSubscription').eql?('true')
  end

  def check_in_items?(field, map)
    map.dig(field, 'checkinItems').eql?('true')
  end
end
