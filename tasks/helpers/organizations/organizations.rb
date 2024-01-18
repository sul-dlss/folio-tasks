# frozen_string_literal: true

# Module to encapsulate methods used by organizations rake tasks
module OrganizationsTaskHelpers
  def organizations_xml(file)
    Nokogiri::XML(File.open("#{Settings.xml}/organizations/#{file}")).xpath('//vendor')
  end

  def organizations_tsv(file)
    CSV.parse(File.open("#{Settings.tsv}/organizations/#{file}"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, category_uuids)
    hash = {
      'id' => determine_org_uuid(vendor_code(obj, acq_unit), Settings.okapi.url.to_s),
      'name' => obj.at_xpath('name')&.text,
      'code' => vendor_code(obj, acq_unit),
      'exportToAccounting' => export_to_accounting?(obj.at_xpath('vendorID')&.text),
      'status' => 'Active',
      'isVendor' => true,
      'erpCode' => update_customer_number(obj.at_xpath('customerNumber')&.text),
      'acqUnitIds' => [
        acq_unit_uuid.to_s
      ],
      'vendorCurrencies' => vendor_currencies(obj),
      'claimingInterval' => claiming_interval(obj),
      'liableForVat' => tax_paid_to_vendor?(obj)
    }
    hash.store('addresses', org_addresses(obj, category_uuids))
    hash.store('phoneNumbers', org_phones(obj, category_uuids))
    hash.store('emails', org_emails(obj, category_uuids))

    hash.compact
  end

  def organization_hash_update(obj, acq_unit_uuid)
    obj['code'] = "#{obj['code']}-SUL"
    obj['status'] = 'Active'
    obj['isVendor'] = false
    obj['aliases'] = [{ value: obj['aliases'] }] if obj['aliases']
    obj['urls'] = [{ value: obj['urls'] }] if obj['urls']
    obj['acqUnitIds'] = [acq_unit_uuid.to_s]
    obj
  end

  def migrate_error_orgs(acq_unit, acq_unit_uuid)
    {
      'name' => "#{acq_unit} Migration Error",
      'code' => "MIGRATE-ERR-#{acq_unit}",
      'status' => 'Active',
      'isVendor' => true,
      'acqUnitIds' => [acq_unit_uuid]
    }
  end

  def export_to_accounting?(vendor_id)
    true unless vendor_id.end_with?('-999', '-9999')
  end

  def tax_paid_to_vendor?(obj)
    return true if obj.at_xpath('taxPaidToVendor')&.text.eql?('true')

    false
  end

  def update_customer_number(customer_number)
    return if customer_number.nil?

    return customer_number.gsub(/9000$/, 'FEEDER') if customer_number.end_with?('9000')

    return customer_number.gsub(/9001$/, 'FEEDER1') if customer_number.end_with?('9001')

    return customer_number.gsub(/FEEDERACH$/, 'FEEDER') if customer_number.end_with?('FEEDERACH')

    customer_number
  end

  def vendor_code(obj, acq_unit)
    "#{obj.at_xpath('vendorID')&.text}-#{acq_unit}"
  end

  def vendor_addresses(obj)
    addresses = []
    obj.xpath('vendorAddress').each do |address|
      next if address.elements.empty?

      addresses.push(address)
    end
    addresses
  end

  def claiming_interval(obj)
    return nil if obj.at_xpath('vendorCycle/claimPeriod')&.text.to_i.zero?

    obj.at_xpath('vendorCycle/claimPeriod')&.text.to_i
  end

  def primary(obj, attr_value)
    # primary is <addressIdx>1</addressIdx> and entry where name is attr_value
    # returns nil if no primary
    obj.at_xpath("./vendorAddress[addressIdx[text()='1'] and entry[@name='#{attr_value}']]")
  end

  def category(node, category_uuids)
    # <addressCategory>Orders, Payments, Claims</addressCategory>
    categories = []
    node.at_xpath('addressCategory').text.split(', ').each do |category|
      categories.push(category_uuids.fetch(category, nil)) unless category.nil?
    end
    categories.compact
  end

  def currency_codes
    JSON.parse(File.read("#{Settings.json}/organizations/currency_codes.json"))
  end

  def vendor_currencies(obj)
    # there is only one <vendorCurrency> per <vendor> record but json expects array
    currencies = [currency_codes.fetch(obj.at_xpath('vendorCurrency')&.text, nil)].compact
    return if currencies.empty?

    currencies
  end

  def determine_org_uuid(legacy_identifier, okapi_url)
    FolioUuid.new.generate(okapi_url, 'organizations', legacy_identifier)
  end

  def organizations_id(code)
    response = FolioRequest.new.get_cql('/organizations/organizations',
                                        "code==#{code.dump}")['organizations']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def organizations_delete(id)
    FolioRequest.new.delete("/organizations/organizations/#{id}")
  end

  def organizations_post(obj)
    FolioRequest.new.post('/organizations/organizations', obj.to_json)
  end

  def organizations_put(id, obj)
    FolioRequest.new.put("/organizations/organizations/#{id}", obj.to_json)
  end
end
