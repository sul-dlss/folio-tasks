# frozen_string_literal: true

require_relative 'folio_request'
require_relative '../../lib/folio_uuid'

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

  def owners_json
    JSON.parse(File.read("#{Settings.json}/users/owners.json"))
  end

  def owners_post(hash)
    @@folio_request.post('/owners', hash.to_json)
  end

  def manual_charges_json
    JSON.parse(File.read("#{Settings.json}/users/manual_charges.json"))
  end

  def manual_charges_post(hash)
    @@folio_request.post('/feefines', hash.to_json)
  end

  def conditions_json
    JSON.parse(File.read("#{Settings.json}/users/conditions.json"))
  end

  def conditions_put(id, hash)
    @@folio_request.put("/patron-block-conditions/#{id}", hash.to_json)
  end

  def templates_json
    JSON.parse(File.read("#{Settings.json}/users/templates.json"))
  end

  def templates_post(hash)
    @@folio_request.post('/manual-block-templates', hash.to_json)
  end

  def limits_json
    JSON.parse(File.read("#{Settings.json}/users/limits.json"))
  end

  def limits_post(hash)
    @@folio_request.post('/patron-block-limits', hash.to_json)
  end

  def user_get(username)
    @@folio_request.get_cql('/users', "username==#{username}")
  end

  def deterministic_user_id(username)
    FolioUuid.new.generate(Settings.okapi.url.to_s, 'users', username)
  end

  def user_login(credentials)
    @@folio_request.post('/authn/credentials', credentials.to_json)
  end

  def user_perms(permissions)
    @@folio_request.post('/perms/users', permissions.to_json)
  end

  def user_service_point(service_point)
    @@folio_request.post('/service-points-users', service_point.to_json)
  end

  def user_service_point_hash(user_id, service_point_id)
    {
      'userId' => user_id,
      'servicePointsIds' => [service_point_id],
      'defaultServicePointId' => service_point_id
    }
  end

  def user_post(user)
    @@folio_request.post('/users', user.to_json)
  end

  def user_update(users)
    @@folio_request.post('/user-import', users.to_json)
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
    hash = @@folio_request.get('/waives?limit=100')
    trim_hash(hash, 'waivers')
    hash.to_json
  end

  def pull_refunds
    hash = @@folio_request.get('/refunds?limit=100')
    trim_hash(hash, 'refunds')
    hash.to_json
  end

  def pull_owners
    hash = @@folio_request.get('/owners?limit=50')
    trim_hash(hash, 'owners')
    hash.to_json
  end

  def pull_manual_charges
    hash = @@folio_request.get_cql('/feefines?limit=100', 'automatic==false')
    trim_hash(hash, 'feefines')
    hash.to_json
  end

  def pull_payments
    hash = @@folio_request.get('/payments?limit=100')
    trim_hash(hash, 'payments')
    hash.to_json
  end

  def pull_conditions
    hash = @@folio_request.get('/patron-block-conditions?limit=100')
    trim_hash(hash, 'patronBlockConditions')
    hash.to_json
  end

  def pull_templates
    hash = @@folio_request.get('/manual-block-templates?limit=100')
    trim_hash(hash, 'manualBlockTemplates')
    hash.to_json
  end

  def pull_limits
    hash = @@folio_request.get('/patron-block-limits?limit=100')
    trim_hash(hash, 'patronBlockLimits')
    hash.to_json
  end

  def pull_permission_sets
    hash = @@folio_request.get('/perms/permissions?limit=9999&length=9999&query=mutable==true')
    trim_hash(hash, 'permissions')
    hash.to_json
  end
end
