# frozen_string_literal: true

require 'csv'
require_relative '../helpers/acq_units'
require_relative '../helpers/uuids/acquisitions'

namespace :acquisitions do
  include AcquisitionsUnitsTaskHelpers, AcquisitionsUuidsHelpers

  desc 'delete acquisitions units from folio'
  task :delete_acq_units do
    acq_units = AcquisitionsUuidsHelpers.acq_units
    acq_units_csv.each do |obj|
      id = acq_units.fetch(obj['name'], nil)
      acq_units_delete(id)
    end
  end
end
