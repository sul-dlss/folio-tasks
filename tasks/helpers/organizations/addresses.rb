# frozen_string_literal: true

# Module to encapsulate org address methods used by organizations rake tasks
module AddressHelpers
  def org_addresses(obj, category_uuids)
    primary_address = primary(obj, 'Street')
    return if primary_address.nil?

    list = []
    vendor_addresses(obj).each do |address|
      hash = address_object(address, primary_address, category_uuids)
      list << hash unless hash.empty?
    end
    list
  end

  def address_object(node, primary_address, category_uuids)
    hash = {
      'city' => city(node),
      'stateRegion' => state_region(node),
      'zipCode' => zip_code(node),
      'country' => country(node)
    }.compact
    add_address_lines(hash, node)
    hash.store('isPrimary', true) if node == primary_address
    hash.store('categories', category(node, category_uuids)) unless category(node, category_uuids).empty?

    hash
  end

  def add_address_lines(hash, node)
    if node.xpath('entry[@name="Street"]').length == 2
      hash.store('addressLine2', node.xpath('entry[@name="Street"]').last&.text)
    end
    hash.store('addressLine1', node.xpath('entry[@name="Street"]').first&.text)
    hash.compact

    hash
  end

  def city(node)
    city = node.at_xpath('entry[@name="City, State"]')&.text&.split(/,\s*/)
    return city[0] unless city.nil?
  end

  def state_region(node)
    state_region = node.at_xpath('entry[@name="City, State"]')&.text&.split(/,\s*/)
    return state_region[1] unless state_region.nil?
  end

  def zip_code(node)
    node.at_xpath('entry[@name="Zip"]')&.text
  end

  def country(node)
    name = node.at_xpath('entry[@name="Country"]')&.text
    country_codes.fetch(name&.downcase, name)
  end

  def country_codes
    JSON.parse(File.read("#{Settings.json}/organizations/country_codes.json"))
  end
end
