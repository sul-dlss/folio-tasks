# frozen_string_literal: true

require_relative '../helpers/tsv_user'
require_relative '../helpers/uuids/uuids'

namespace :tsv_users do
  include TsvUserTaskHelpers

  desc 'assign users a default service point'
  task :assign_service_points do
    service_points_assign(user_acq_units_and_permission_sets_tsv)
  end

  desc 'assign default service point to the app users'
  task :assign_app_user_service_points do
    service_points_assign(app_users_permission_sets_tsv)
  end
end
