# frozen_string_literal: true

require_relative 'folio_request'
require_relative '../../lib/folio_uuid'

# Module to encapsulate methods used by user_settings rake tasks
module UsersTaskHelpers
  include FolioRequestHelper

  def groups_post(obj)
    @@folio_request.post('/groups', obj)
  end

  def address_types_json
    JSON.parse(File.read("#{Settings.json}/users/addresstypes.json"))
  end

  def address_types_post(hash)
    @@folio_request.post('/addresstypes', hash)
  end

  def waivers_json
    JSON.parse(File.read("#{Settings.json}/users/waivers.json"))
  end

  def waivers_post(hash)
    @@folio_request.post('/waives', hash)
  end

  def waivers_delete(id)
    @@folio_request.delete("/waives/#{id}")
  end

  def payments_json
    JSON.parse(File.read("#{Settings.json}/users/payments.json"))
  end

  def payments_post(hash)
    @@folio_request.post('/payments', hash)
  end

  def payments_delete(id)
    @@folio_request.delete("/payments/#{id}")
  end

  def refunds_json
    JSON.parse(File.read("#{Settings.json}/users/refunds.json"))
  end

  def refunds_post(hash)
    @@folio_request.post('/refunds', hash)
  end

  def refunds_delete(id)
    @@folio_request.delete("/refunds/#{id}")
  end

  def comments_json
    JSON.parse(File.read("#{Settings.json}/users/comments.json"))
  end

  def comments_post(hash)
    @@folio_request.post('/comments', hash)
  end

  def comments_delete(id)
    @@folio_request.delete("/comments/#{id}")
  end

  def owners_json
    JSON.parse(File.read("#{Settings.json}/users/owners.json"))
  end

  def owners_post(hash)
    @@folio_request.post('/owners', hash)
  end

  def owners_delete(id)
    @@folio_request.delete("/owners/#{id}")
  end

  def manual_charges_json
    JSON.parse(File.read("#{Settings.json}/users/manual_charges.json"))
  end

  def manual_charges_post(hash)
    @@folio_request.post('/feefines', hash)
  end

  def manual_charges_delete(id)
    @@folio_request.delete("/feefines/#{id}")
  end

  def conditions_json
    JSON.parse(File.read("#{Settings.json}/users/conditions.json"))
  end

  def conditions_put(id, hash)
    @@folio_request.put("/patron-block-conditions/#{id}", hash)
  end

  def templates_json
    JSON.parse(File.read("#{Settings.json}/users/templates.json"))
  end

  def templates_post(hash)
    @@folio_request.post('/manual-block-templates', hash)
  end

  def templates_delete(id)
    @@folio_request.delete("/manual-block-templates/#{id}")
  end

  def limits_json
    JSON.parse(File.read("#{Settings.json}/users/limits.json"))
  end

  def limits_post(hash)
    @@folio_request.post('/patron-block-limits', hash)
  end

  def limits_delete(id)
    @@folio_request.delete("/patron-block-limits/#{id}")
  end

  def user_get(username)
    @@folio_request.get_cql('/users', "username==#{username}")
  end

  def deterministic_user_id(username)
    FolioUuid.new.generate('deterministic_user_id', 'users', username)
  end

  def user_service_point(service_point)
    @@folio_request.post('/service-points-users', service_point)
  end

  def user_service_point_hash(user_id, service_point_id)
    {
      'userId' => user_id,
      'servicePointsIds' => [service_point_id],
      'defaultServicePointId' => service_point_id
    }
  end

  def user_post(user)
    @@folio_request.post('/users', user)
  end

  def user_update(users)
    @@folio_request.post('/user-import', users)
  end

  def patron_group_get(id)
    @@folio_request.get("/groups/#{id}")
  end

  def patron_group(user)
    patron_group_id = user['patronGroup']
    patron_group_get(patron_group_id) if patron_group_id
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

  def pull_comments
    hash = @@folio_request.get('/comments?limit=100')
    trim_hash(hash, 'comments')
    hash.to_json
  end

  def pull_owners
    hash = @@folio_request.get('/owners?limit=50')
    trim_hash(hash, 'owners')
    hash.to_json
  end

  def pull_manual_charges
    hash = @@folio_request.get('/feefines?limit=100&query=automatic==false')
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
end
