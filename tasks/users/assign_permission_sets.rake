# frozen_string_literal: true

require_relative '../helpers/tsv_user'

namespace :tsv_users do
  include TsvUserTaskHelpers

  desc 'assign permission sets to a user'
  task :assign_permission_sets do
    perms_assign(user_acq_units_and_permission_sets_tsv)
  end

  desc 'assign permission sets to the app users'
  task :assign_app_user_psets do
    perms_assign(app_users_permission_sets_tsv)
  end
end
