# frozen_string_literal: true

# Module to encapsulate methods used by organizations rake tasks
module OrganizationsTaskHelpers
  def organizations_xml(file)
    Nokogiri::XML(File.open("#{Settings.xml}/#{file}")).xpath('//vendor')
  end

  def organizations_tsv(file)
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/#{file}"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def organization_hash_from_xml(obj, acq_unit, acq_unit_uuid, map)
    hash = {
      'name' => obj.at_xpath('name')&.text,
      'code' => vendor_code(obj, acq_unit),
      'exportToAccounting' => export_to_accounting?(obj.at_xpath('vendorID')&.text),
      'status' => 'Active',
      'isVendor' => true,
      'erpCode' => obj.at_xpath('customerNumber')&.text,
      'acqUnitIds' => [
        acq_unit_uuid.to_s
      ]
    }
    hash.store('addresses', org_addresses(obj, map))
    hash.store('phoneNumbers', org_phones(obj, map))
    hash.store('emails', org_emails(obj, map))

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
    return true unless vendor_id.end_with?('-999', '-9999')
  end

  def vendor_code(obj, acq_unit)
    "#{obj.at_xpath('vendorID')&.text}-#{acq_unit}"
  end

  def primary(obj, attr_value)
    if obj.xpath("./vendorAddress[addressIdx[text()='1'] and entry[@name='#{attr_value}']]").any?
      obj.xpath("./vendorAddress[addressIdx[text()='1'] and entry[@name='#{attr_value}']]").first
    elsif obj.xpath("./vendorAddress[addressIdx[text()='0'] and entry[@name='#{attr_value}']]").any?
      obj.xpath("./vendorAddress[addressIdx[text()='0'] and entry[@name='#{attr_value}']]").first
    elsif obj.xpath("./vendorAddress[addressIdx[text()='2'] and entry[@name='#{attr_value}']]").any?
      obj.xpath("./vendorAddress[addressIdx[text()='2'] and entry[@name='#{attr_value}']]").first
    end
    # returns nil if no primary
  end

  def category(node, map)
    category = node.at_xpath('addressIdx')&.text
    return if category.to_i > 2

    map.fetch(category) unless category.nil?
  end

  def organizations_id(code)
    response = FolioRequest.new.get_cql('/organizations/organizations',
                                        "code==#{CGI.escape(code).dump}")['organizations']
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
