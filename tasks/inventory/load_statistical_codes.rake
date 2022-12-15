# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load statistical code types into folio'
  task :load_statistical_code_types do
    statistical_code_types_json.each do |obj|
      statistical_code_types_post(obj)
    end
  end

  desc 'load statistical codes into folio'
  task :load_statistical_codes do
    statistical_codes_json.each do |obj|
      statistical_codes_post(obj)
    end
  end
end
