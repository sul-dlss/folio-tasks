# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load alternative title types into folio'
  task :load_alt_title_types do
    alt_title_types_csv.each do |obj|
      alt_title_types_post(obj)
    end
  end
end
