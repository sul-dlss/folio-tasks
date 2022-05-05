# frozen_string_literal: true

require_relative '../helpers/tsv_user'

namespace :tsv_users do
  include TsvUserTaskHelpers

  desc 'assign permission sets to a user'
  task :assign_permission_sets do
    psets_from_cols = user_acq_units_and_permission_sets_tsv[0].keys
    psets_from_cols.delete('SUNetID')
    psets_from_cols.delete('Acq Unit')
    pset_hash = {}
    folio_request.get('/perms/permissions?length=10000&query=(mutable==true)')['permissions'].each do |permission|
      pset_hash[permission['displayName']] = permission['id']
    end
    user_acq_units_and_permission_sets_tsv.each do |line|
      username = user_get(line['SUNetID'])
      username && username['users'].each do |user|
        user_permissions_get(user['id'])['permissionNames'].each do |permission|
          if permission['mutable'] && (psets_from_cols.include? permission['displayName'])
            folio_request
              .delete("/perms/users/#{user['id']}/permissions/#{permission['permissionName']}?indexField=userId")
          end
        end
        psets_from_cols.each do |pset|
          if line[pset] && pset_hash[pset]
            pset_obj = { 'permissionName' => pset_hash[pset] }
            folio_request.post("/perms/users/#{user['id']}/permissions?indexField=userId", pset_obj.to_json)
          end
        end
      end
    end
  end
end
