# frozen_string_literal: true

# Module to encapsulate email methods used by organizations rake tasks
module EmailHelpers
  # rubocop: disable Metrics/CyclomaticComplexity
  def org_emails(obj, category_uuids)
    primary_email = primary(obj, 'Email for po/claim') || primary(obj, 'E-Address')
    return if primary_email.nil?

    list = []
    obj.xpath('vendorAddress').each do |address|
      category = category(address, category_uuids)
      claims_hash = claims_object(address, primary_email, category)
      list << claims_hash if claims_hash&.any?
      email_hash = email_object(address, primary_email, category, list)
      list << email_hash if email_hash&.any?
    end
    list.compact
  end
  # rubocop: enable Metrics/CyclomaticComplexity

  def claims_object(node, primary_email, category)
    return if claims_email(node).nil?

    hash = {
      'value' => claims_email(node),
      'categories' => category
    }
    hash.store('isPrimary', true) if node == primary_email
    hash.compact
  end

  def claims_email(node)
    node.at_xpath('entry[@name="Email for po/claim"]')&.text
  end

  def email_object(node, primary_email, category, list)
    return if email(node).nil?

    hash = {
      'value' => email(node),
      'categories' => category
    }
    hash.store('isPrimary', true) if node == primary_email && list.none? { |h| h['isPrimary'] }
    hash.compact
  end

  def email(node)
    node.at_xpath('entry[@name="E-Address"]')&.text
  end
end
