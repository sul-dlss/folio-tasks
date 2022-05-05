# frozen_string_literal: true

# Module to encapsulate phone number methods used by organizations rake tasks
module PhoneNumberHelpers
  def org_phones(obj, map)
    primary_phone = primary(obj, 'Phone')
    return if primary_phone.nil?

    list = []
    obj.xpath('vendorAddress').each do |address|
      category = [category(address, map)]
      phone_hash = phone_object(address, primary_phone, category)
      fax_hash = fax_object(address, category)
      list << phone_hash unless phone_hash.nil?
      list << fax_hash unless fax_hash.nil?
    end
    list
  end

  def phone_object(node, primary_phone, category)
    return if phone(node).nil?

    hash = {
      'phoneNumber' => phone(node),
      'type' => 'Office'
    }.compact
    hash.store('isPrimary', true) if node == primary_phone
    hash.store('categories', category) unless hash['phoneNumber'].nil? || category.none?

    hash
  end

  def phone(node)
    node.at_xpath('entry[@name="Phone"]')&.text
  end

  def fax_object(node, category)
    return if fax(node).nil?

    hash = {
      'phoneNumber' => fax(node),
      'type' => 'Fax'
    }.compact
    hash.store('categories', category) unless hash['phoneNumber'].nil? || category.none?

    hash
  end

  def fax(node)
    node.at_xpath('entry[@name="FAX"]')&.text
  end
end
