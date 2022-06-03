# frozen_string_literal: true

require_relative '../helpers/tsv_user'
require_relative '../helpers/uuids/uuids'

namespace :tsv_users do
  include TsvUserTaskHelpers, Uuids

  desc 'assign users a default service point'
  task :assign_service_points do
    service_point_hash = service_points
    user_acq_units_and_permission_sets_tsv.each do |obj|
      service_point = obj['Service Point']
      service_point_id = service_point_hash[service_point]
      users = user_get(obj['SUNetID'])
      service_point_id && users && users['users'].each do |user|
        path = "/request-preference-storage/request-preference?query=userId%3D%3D#{user['id']}"
        request_pref = @@folio_request.get(path)['requestPreferences'][0]
        request_pref['defaultServicePointId'] = service_point_id
        path = "/request-preference-storage/request-preference/#{request_pref['id']}"
        @@folio_request.put(path, request_pref.to_json)
      end
    end
  end
end
