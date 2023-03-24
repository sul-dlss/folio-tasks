# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load identifier types into folio'
  task :load_identifier_types do
    identifier_types_csv.each do |obj|
      identifier_types_post(obj)
    end
  end
end
