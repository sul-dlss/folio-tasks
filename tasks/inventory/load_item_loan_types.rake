# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load item loan types into folio'
  task :load_item_loan_types do
    item_loan_types_csv.each do |obj|
      item_loan_types_post(obj)
    end
  end
end