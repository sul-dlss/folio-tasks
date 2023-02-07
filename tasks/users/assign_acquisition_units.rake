# frozen_string_literal: true

require_relative '../helpers/tsv_user'
require_relative '../helpers/acq_units'
require_relative '../helpers/uuids/acquisitions'

namespace :tsv_users do
  include TsvUserTaskHelpers, AcquisitionsUnitsTaskHelpers, AcquisitionsUuidsHelpers

  desc 'assign acquisition units to all users'
  task :assign_acquisition_units do
    acq_units_assign(AcquisitionsUuidsHelpers.acq_units, AcquisitionsUuidsHelpers.acq_unit_membership)
  end

  desc 'assign acquisition units to the admin user'
  task :assign_admin_acquisition_units do
    admin_acq_units_assign(AcquisitionsUuidsHelpers.acq_units)
  end
end
