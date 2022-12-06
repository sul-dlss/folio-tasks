# frozen_string_literal: true

require 'csv'
require_relative '../helpers/orders/order_settings'
require_relative '../../lib/folio_uuid'

namespace :acquisitions do
  include OrderSettingsHelpers

  desc 'load acquisition methods for orders'
  task :load_acq_methods do
    acq_methods_tsv.each do |obj|
      acq_methods_post(obj)
    end
  end
end
