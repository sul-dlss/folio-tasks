# frozen_string_literal: true

# Module to encapsulate order type methods used by orders rake tasks
module OrderTypeHelpers
  def order_type_csv(file)
    CSV.parse(File.open("#{Settings.tsv_orders}/#{file}"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def order_type_mapping(file, material_type_map, acq_method_map)
    map = {}
    order_type_csv(file).each do |row|
      map[row['Symph_order_type']] = row.to_h
    end
    map.each_value do |obj|
      obj['materialType'] = material_type_uuid(obj['materialType'], material_type_map)
      obj['acquisitionMethod'] = acquisition_method_uuid(obj['acquisitionMethod'], acq_method_map)
    end
    map
  end

  def order_type(field, map)
    map.dig(field, 'orderType')
  end

  def acquisition_method(field, map)
    map.dig(field, 'acquisitionMethod')
  end

  def acquisition_method_uuid(value, acq_method_map)
    return acq_method_map['Other'] if acq_method_map[value].nil?

    acq_method_map[value]
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

  def payment_status(field, map, po_line_data)
    case po_line_data['HOLDNG_CODE']
    when /^LAW/
      if field.eql?('GIFTSER') || field.eql?('GIFTMONO')
        'Payment Not Required'
      elsif order_type(field, map).eql?('Ongoing')
        'Ongoing'
      elsif po_line_data['DIST_DATE_LOAD'].match?(/\d{8}/)
        'Fully Paid'
      else
        'Awaiting Payment'
      end
    else
      return 'Awaiting Payment' if order_type(field, map).eql?('One-Time')

      'Ongoing'
    end
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
    # Receiving workflow: Based on value of poline.checkinItems
    # Synchronized = false
    # Independent = true
    map.dig(field, 'checkinItems').eql?('true')
  end
end
