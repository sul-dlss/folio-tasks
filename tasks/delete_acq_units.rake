# frozen_string_literal: true

require 'csv'
require_relative 'helpers/acq_units'

desc 'delete acquisitions units from folio'
task :delete_acq_units do
  include AcquisitionsUnitsTaskHelpers
  acq_units_csv.each do |obj|
    acq_units_delete(obj['id'])
  end
end
