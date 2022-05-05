# frozen_string_literal: true

# Module to encapsulate org address methods used by organizations rake tasks
module AddressHelpers
  def org_addresses(obj, map)
    primary_address = primary(obj, 'Street')
    return if primary_address.nil?

    list = []
    obj.xpath('vendorAddress').each do |address|
      hash = address_object(address, primary_address, map)
      list << hash unless hash.empty?
    end
    list
  end

  def address_object(node, primary_address, map)
    hash = {
      'addressLine1' => address_line(node),
      'city' => city(node),
      'stateRegion' => state_region(node),
      'zipCode' => zip_code(node),
      'country' => country(node)
    }.compact
    hash.store('isPrimary', true) if node == primary_address
    cat = [category(node, map)]
    hash.store('categories', cat) unless hash['addressLine1'].nil? || cat.none?

    hash
  end

  def address_line(node)
    node.at_xpath('entry[@name="Street"]')&.text
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
    JSON.parse(File.read("#{Settings.json}/country_codes.json"))
  end
end
