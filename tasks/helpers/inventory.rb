# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by inventory settings rake task
module InventoryTaskHelpers
  include FolioRequestHelper

  def item_loan_types_csv
    CSV.parse(File.open("#{Settings.tsv}/inventory/item-loan-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def item_loan_types_post(obj)
    @@folio_request.post('/loan-types', obj.to_json)
  end

  def alt_title_types_csv
    CSV.parse(File.open("#{Settings.tsv}/inventory/alt-title-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def alt_title_types_post(obj)
    @@folio_request.post('/alternative-title-types', obj.to_json)
  end

  def item_note_types_csv
    CSV.parse(File.open("#{Settings.tsv}/inventory/item-note-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def item_note_types_post(obj)
    @@folio_request.post('/item-note-types', obj.to_json)
  end

  def material_types_csv
    CSV.parse(File.open("#{Settings.tsv}/inventory/material-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def material_types_post(obj)
    @@folio_request.post('/material-types', obj.to_json)
  end
end
