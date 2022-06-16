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

  desc 'load po lines limit configuration for orders'
  task :load_po_lines_limit do
    po_lines_limit_post(po_lines_limit)
  end
end
