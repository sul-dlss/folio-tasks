# frozen_string_literal: true

require 'csv'
require_relative '../helpers/erm'

namespace :erm do
  include ErmTaskHelpers

  desc 'load e-usage data providers into folio'
  task :load_data_providers do
    data_providers_tsv.each do |obj|
      data_provider = data_providers_hash(obj)
      data_providers_post(data_provider)
    end
  end
end
