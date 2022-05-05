# frozen_string_literal: true

require_relative '../helpers/tsv_user'

namespace :tsv_users do
  include TsvUserTaskHelpers

  desc 'assign acquisition units to a user'
  task :assign_acquisition_units do
    acq_unit_hash = {}
    folio_request.get('/acquisitions-units/units')['acquisitionsUnits'].each do |obj|
      acq_unit_hash[obj['name']] = obj['id']
    end
    membership_hash = {}
    folio_request.get('/acquisitions-units/memberships?limit=10000')['acquisitionsUnitMemberships'].each do |obj|
      key = obj['acquisitionsUnitId'] + obj['userId']
      membership_hash[key] = obj['id']
    end
    user_acq_units_and_permission_sets_tsv.each do |obj|
      acq_unit = obj['Acq Unit']
      acq_unit_id = acq_unit_hash[acq_unit]
      users = user_get(obj['SUNetID'])
      users && users['users'].each do |user|
        if acq_unit_id && !membership_hash[acq_unit_id + user['id']]
          acq_membership_obj = { 'userId' => user['id'], 'acquisitionsUnitId' => acq_unit_id }
          folio_request.post('/acquisitions-units/memberships', acq_membership_obj.to_json)
        end
      end
    end
  end
end
