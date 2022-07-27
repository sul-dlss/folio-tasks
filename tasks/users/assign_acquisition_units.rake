# frozen_string_literal: true

require_relative '../helpers/tsv_user'
require_relative '../helpers/acq_units'

namespace :tsv_users do
  include TsvUserTaskHelpers, AcquisitionsUnitsTaskHelpers

  desc 'assign acquisition units to a user'
  task :assign_acquisition_units do
    acq_units_assign
  end
end
