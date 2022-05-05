# frozen_string_literal: true

require 'csv'
require_relative '../../lib/folio_request'
require_relative '../helpers/acq_units'

namespace :acquisitions do
  include AcquisitionsUnitsTaskHelpers

  desc 'load acquisitions units into folio'
  task :load_acq_units do
    acq_units_csv.each do |obj|
      acq_units_post(obj)
    end
  end
end
