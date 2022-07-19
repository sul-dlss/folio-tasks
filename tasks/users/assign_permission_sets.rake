# frozen_string_literal: true

require_relative '../helpers/tsv_user'

namespace :tsv_users do
  include TsvUserTaskHelpers

  desc 'assign permission sets to a user'
  task :assign_permission_sets do
    perms_assign
  end
end
