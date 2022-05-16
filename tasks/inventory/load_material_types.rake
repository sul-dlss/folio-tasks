# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load material types into folio'
  task :load_material_types do
    material_types_csv.each do |obj|
      material_types_post(obj)
    end
  end
end
