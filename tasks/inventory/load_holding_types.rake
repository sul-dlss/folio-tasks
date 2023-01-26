# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load holdings types into folio'
  task :load_holdings_types do
    holdings_types_csv.each do |obj|
      holdings_types_post(obj)
    end
  end
end
