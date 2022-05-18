# frozen_string_literal: true

# Module to encapsulate methods used by create orders yaml rake tasks
# rubocop: disable Metrics/ModuleLength
module OrderYamlTaskHelpers
  def orders_tsv(file)
    CSV.parse(File.open("#{Settings.tsv_orders}/#{file}"), headers: true, col_sep: "\t",
                                                           liberal_parsing: true).map(&:to_h)
  end

  def modify_order_data(tsv_hash, yaml_hash)
    if yaml_hash[tsv_hash['ORD_ID'].to_s]['compositePoLines'].key?(tsv_hash['ORDLINE_KEY'].to_s)
      add_fund_distribution(tsv_hash, yaml_hash)
    else
      add_orderline(tsv_hash, yaml_hash)
    end
    yaml_hash
  end

  def add_fund_distribution(tsv_hash, yaml_hash)
    yaml_hash[(tsv_hash['ORD_ID']).to_s]['compositePoLines'][(tsv_hash['ORDLINE_KEY']).to_s]['fundDistribution']
      .push(fund(tsv_hash)).uniq!
  end

  def add_orderline(tsv_hash, yaml_hash)
    yaml_hash[(tsv_hash['ORD_ID']).to_s]['compositePoLines'].merge!(orderline(tsv_hash))
  end

  def add_order_xinfo(tsv_hash, yaml_hash)
    note_fields = %w[INSTRUCT NOTE COMMENT MULTIYEAR STREAMING OPENACCESS]
    tag_fields = %w[BIGDEAL DATA]
    return map_to_notes(tsv_hash, yaml_hash) if note_fields.include?(tsv_hash['XINFO_FIELD'])
    return map_to_tags(tsv_hash, yaml_hash) if tag_fields.include?(tsv_hash['XINFO_FIELD']) &&
                                               tsv_hash['LIB'].eql?('SUL')
  end

  def add_orderlin1_xinfo(tsv_hash, yaml_hash)
    note_fields = %w[DESC COMMENT CONTACT NOTIFY]
    return map_to_notes(tsv_hash, yaml_hash) if note_fields.include?(tsv_hash['XINFO_FIELD'])
  end

  def map_to_notes(tsv_hash, yaml_hash)
    if yaml_hash[tsv_hash['ORD_ID'].to_s].key?('notes')
      yaml_hash[tsv_hash['ORD_ID'].to_s]['notes'].push(notes(tsv_hash)).uniq!
    else
      yaml_hash[tsv_hash['ORD_ID'].to_s].store('notes', [notes(tsv_hash)])
    end
    yaml_hash
  end

  def notes(tsv_hash)
    new_data = cleanup(tsv_hash['DATA'])
    # prefix DATA with the FIELD:
    "#{tsv_hash['XINFO_FIELD']}: #{new_data}"
  end

  def map_to_tags(tsv_hash, yaml_hash)
    if yaml_hash[tsv_hash['ORD_ID'].to_s].key?('tags')
      yaml_hash[tsv_hash['ORD_ID'].to_s]['tags']['tagList'].push(tags(tsv_hash)).uniq!
    else
      yaml_hash[tsv_hash['ORD_ID'].to_s].store('tags', 'tagList' => [tags(tsv_hash)])
    end
    yaml_hash
  end

  def tags(tsv_hash)
    new_data = tag_data(tsv_hash['DATA'])
    # prepend XINFO_FIELD with "SUL" and append ":", i.e. "SULBIGDEAL:"
    "SUL#{tsv_hash['XINFO_FIELD']}:#{new_data}"
  end

  def tag_data(data)
    # strip subfield "a" from the beginning and "<ENTRY" from the end of DATA, replace spaces with underscores
    data.gsub(/^a{1}/, '').gsub(/<ENTRY$/, '').tr(' ', '_')
  end

  def add_orderline_xinfo(tsv_hash, yaml_hash)
    fields = %w[ACCOUNT FUND SELECTOR]
    return modify_orderline(tsv_hash, yaml_hash) if fields.include?(tsv_hash['XINFO_FIELD'])
  end

  def modify_orderline(tsv_hash, yaml_hash)
    yaml_hash[tsv_hash['ORD_ID'].to_s]['compositePoLines'][tsv_hash['ORDLINE_KEY'].to_s][
      tsv_hash['XINFO_FIELD']] = cleanup(tsv_hash['DATA'])
    yaml_hash
  end

  def cleanup(data)
    # strip subfield "a" from the beginning and "<ENTRY" from the end of DATA
    data.gsub(/^a{1}/, '').gsub(/<ENTRY$/, '')
  end

  def modify_yaml_file(new_data, filename)
    File.open(filename, 'w') do |file|
      file.puts new_data.to_yaml
    end
  end

  def write_yaml_file(tsv_hash, filename)
    File.open(filename, 'w') do |file|
      file.puts order(tsv_hash).to_yaml
    end
  end

  def order(obj)
    {
      (obj['ORD_ID']).to_s => {
        'ORDER_TYPE' => (obj['ORD_TYPE']).to_s,
        'ORD_DATE_CREATED' => (obj['ORD_DATE_CREATED']).to_s,
        'LIBRARY' => (obj['LIBRARY']).to_s,
        'VENDOR_ID' => (obj['VENDOR_ID']).to_s,
        'compositePoLines' => orderline(obj)
      }
    }
  end

  def orderline(obj)
    {
      (obj['ORDLINE_KEY']).to_s => {
        'ORD_KEY' => (obj['ORD_KEY']).to_s,
        'ORDLINE_NUM' => (obj['ORDLINE_NUM']).to_s,
        'CKEY' => (obj['CKEY']).to_s,
        'TITLE' => (obj['TITLE']).to_s,
        'ORDLINE_UNIT_LIST_PRICE' => (obj['ORDLINE_UNIT_LIST_PRICE']).to_s,
        'COPIES_RCVD' => (obj['COPIES_RCVD']).to_s,
        'BIB_ENTRY' => (obj['BIB_ENTRY']).to_s,
        'PARTS_IN_SET' => (obj['PARTS_IN_SET']).to_s,
        'DIST_DATE_RCVD' => (obj['DIST_DATE_RCVD']).to_s,
        'HOLDNG_CODE' => (obj['HOLDNG_CODE']).to_s,
        'fundDistribution' => [fund(obj)]
      }
    }
  end

  def fund(obj)
    {
      'FUNDING_TYPE' => (obj['FUNDING_TYPE']).to_s,
      'FUNDING_PERCENT' => (obj['FUNDING_PERCENT']).to_s,
      'FUNDING_AMT_ENCUM' => (obj['FUNDING_AMT_ENCUM']).to_s,
      'FUND_ID' => (obj['FUND_ID']).to_s,
      'FUND_NAME' => (obj['FUND_NAME']).to_s
    }
  end
end
# rubocop: enable Metrics/ModuleLength
