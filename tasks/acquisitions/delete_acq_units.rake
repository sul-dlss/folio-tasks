# frozen_string_literal: true

require_relative '../../lib/folio_request'
require_relative '../helpers/acq_units'
require 'csv'

namespace :acquisitions do
  include AcquisitionsUnitsTaskHelpers

  desc 'delete acquisitions units from folio'
  task :delete_acq_units do
    acq_units_csv.each do |obj|
      id = acq_unit_id(obj['name'])
      acq_units_delete(id)
    end
  end
end
