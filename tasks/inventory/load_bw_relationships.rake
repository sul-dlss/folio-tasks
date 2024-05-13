# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load boundwith parts into folio'
  task :load_bw_parts, [:filename] do |_, args|
    bw_parts_csv(args[:filename]).each do |obj|
      bw_parts_post(obj)
    end
  end
end
