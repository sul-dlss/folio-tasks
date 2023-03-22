# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load copy cataloging profiles into folio'
  task :load_copycat_profiles do
    copycat_profiles_json['profiles'].each do |obj|
      copycat_profiles_post(obj)
    end
  end
end
