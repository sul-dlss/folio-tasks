# frozen_string_literal: true

require 'csv'
require_relative '../../lib/folio_request'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load item note types into folio'
  task :load_item_note_types do
    item_note_types_csv.each do |obj|
      item_note_types_post(obj)
    end
  end
end
