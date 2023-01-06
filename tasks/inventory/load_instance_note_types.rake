# frozen_string_literal: true

require 'csv'
require_relative '../helpers/inventory'

namespace :inventory do
  include InventoryTaskHelpers

  desc 'load instance note types into folio'
  task :load_instance_note_types do
    instance_note_types_json['instanceNoteTypes'].each do |obj|
      instance_note_types_post(obj)
    end
  end
end
