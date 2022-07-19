# frozen_string_literal: true

require_relative '../helpers/tsv_user'
require_relative '../helpers/uuids/uuids'

namespace :tsv_users do
  include TsvUserTaskHelpers

  desc 'assign users a default service point'
  task :assign_service_points do
    service_points_assign
  end
end
