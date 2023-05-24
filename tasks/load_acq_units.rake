# frozen_string_literal: true

require 'csv'
require_relative 'helpers/acq_units'

desc 'load acquisitions units into folio'
task :load_acq_units do
  include AcquisitionsUnitsTaskHelpers
  acq_units_csv.each do |obj|
    acq_units_post(obj)
  end
end
