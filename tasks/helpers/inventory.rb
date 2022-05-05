# frozen_string_literal: true

# Module to encapsulate methods used by inventory settings rake tasks
module InventoryTaskHelpers
  def item_note_types_csv
    CSV.parse(File.open("#{Settings.tsv}/inventory/item-note-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def item_note_types_post(obj)
    folio_request.post('/item-note-types', obj.to_json)
  end
end
