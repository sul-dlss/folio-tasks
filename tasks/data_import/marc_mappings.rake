# frozen_string_literal: true

require_relative '../helpers/data_import'

namespace :data_import do
  desc 'load marc bib mappings'
  task :update_marc_bib_mappings do
    marc_bib_mapping_put(marc_bib_mapping_json)
  end

  desc 'load marc holdings mappings'
  task :update_marc_hold_mappings do
    marc_hold_mapping_put(marc_hold_mapping_json)
  end
end
