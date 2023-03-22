# frozen_string_literal: true

require_relative '../helpers/tsv_user'
require_relative '../helpers/acq_units'
require_relative '../helpers/uuids/acquisitions'

namespace :tsv_users do
  include TsvUserTaskHelpers, AcquisitionsUnitsTaskHelpers, AcquisitionsUuidsHelpers

  desc 'assign acquisition units to all users'
  task :assign_acquisition_units do
    acq_units_assign(acq_units, acq_unit_membership, user_acq_units_and_permission_sets_tsv)
  end

  desc 'assign acquisition units to some app_users'
  task :assign_app_user_acq_units do
    acq_units_assign(acq_units, acq_unit_membership, app_users_acq_units_tsv)
  end

  desc 'assign acquisition units to the admin user'
  task :assign_admin_acquisition_units do
    admin_acq_units_assign(acq_units)
  end
end
