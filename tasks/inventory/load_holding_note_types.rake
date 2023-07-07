# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load holdings note types into folio'
  task :load_holdings_note_types do
    holdings_note_types_csv.each do |obj|
      holdings_note_types_post(obj)
    end
  end
end
