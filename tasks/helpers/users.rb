# frozen_string_literal: true

require_relative 'folio_request'

# Module to encapsulate methods used by user_settings rake tasks
module UsersTaskHelpers
  include FolioRequestHelper

  def groups_csv
    CSV.parse(File.open("#{Settings.tsv}/users/patron-groups.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def groups_post(obj)
    @@folio_request.post('/groups', obj.to_json)
  end

  def address_types_json
    JSON.parse(File.read("#{Settings.json}/users/addresstypes.json"))
  end

  def address_types_post(hash)
    @@folio_request.post('/addresstypes', hash.to_json)
  end

  def waivers_json
    JSON.parse(File.read("#{Settings.json}/users/waivers.json"))
  end

  def waivers_post(hash)
    @@folio_request.post('/waives', hash.to_json)
  end

  def payments_json
    JSON.parse(File.read("#{Settings.json}/users/payments.json"))
  end

  def payments_post(hash)
    @@folio_request.post('/payments', hash.to_json)
  end

  def refunds_json
    JSON.parse(File.read("#{Settings.json}/users/refunds.json"))
  end

  def refunds_post(hash)
    @@folio_request.post('/refunds', hash.to_json)
  end

  def fee_fine_owners_json
    JSON.parse(File.read("#{Settings.json}/users/fee_fine_owners.json"))
  end

  def fee_fine_owners_post(hash)
    @@folio_request.post('/owners', hash.to_json)
  end

  def user_get(username)
    @@folio_request.get_cql('/users', "username==#{username}")
  end

  def user_update(user)
    @@folio_request.post('/user-import', user.to_json)
  end

  def patron_group_get(id)
    @@folio_request.get("/groups/#{id}")
  end

  def patron_group(user)
    patron_group_id = user['patronGroup']
    patron_group_get(patron_group_id) if patron_group_id
  end

  def inactive_user(user, affiliation)
    patron_group = patron_group(user)
    user['patronGroup'] = patron_group['group'] if patron_group
    user['active'] = false
    user['customFields'] = { 'affiliation' => affiliation }
    user
  end

  def permission_sets_json
    JSON.parse(File.read("#{Settings.json}/users/permission_sets.json"))
  end

  def permission_sets_post(hash)
    @@folio_request.post('/perms/permissions', hash.to_json)
  end

  def user_permissions_get(uuid)
    @@folio_request.get("/perms/users/#{uuid}/permissions?full=true&indexField=userId")
  end

  def pull_waivers
    hash = @@folio_request.get('/waives')
    trim_hash(hash, 'waivers')
    hash.to_json
  end

  def pull_refunds
    hash = @@folio_request.get('/refunds')
    trim_hash(hash, 'refunds')
    hash.to_json
  end

  def pull_owners
    hash = @@folio_request.get('/owners')
    trim_hash(hash, 'owners')
    hash.to_json
  end

  def pull_payments
    hash = @@folio_request.get('/payments')
    trim_hash(hash, 'payments')
    hash.to_json
  end
end
