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

  def holdings_types_csv
    CSV.parse(File.open("#{Settings.tsv}/inventory/holdings-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def holdings_note_types_csv
    CSV.parse(File.open("#{Settings.tsv}/inventory/holdings-note-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def alt_title_types_post(obj)
    @@folio_request.post('/alternative-title-types', obj.to_json)
  end

  def holdings_types_post(obj)
    @@folio_request.post('/holdings-types', obj.to_json)
  end

  def holdings_note_types_post(obj)
    @@folio_request.post('/holdings-note-types', obj.to_json)
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

  def identifier_types_csv
    CSV.parse(File.open("#{Settings.tsv}/inventory/identifier-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def bw_parts_csv(filename)
    CSV.parse(File.open("#{Settings.tsv}/inventory/#{filename}"), headers: true).map(&:to_h)
  end

  def bw_parts_post(obj)
    @@folio_request.post('/inventory-storage/bound-with-parts', obj.to_json)
  end

  def material_types_post(obj)
    @@folio_request.post('/material-types', obj.to_json)
  end

  def identifier_types_post(obj)
    @@folio_request.post('/identifier-types', obj.to_json)
  end

  def pull_statistical_code_types
    hash = @@folio_request.get_cql('/statistical-code-types', "source='local'&limit=99")
    trim_hash(hash, 'statisticalCodeTypes')
    hash.to_json
  end

  def statistical_code_types_post(obj)
    @@folio_request.post('/statistical-code-types', obj.to_json)
  end

  def statistical_code_types_json
    JSON.parse(File.read("#{Settings.json}/inventory/statistical_code_types.json"))
  end

  def pull_statistical_codes
    hash = @@folio_request.get_cql('/statistical-codes', "source='local'&limit=99")
    trim_hash(hash, 'statisticalCodes')
    hash.to_json
  end

  def statistical_codes_post(obj)
    @@folio_request.post('/statistical-codes', obj.to_json)
  end

  def statistical_codes_json
    JSON.parse(File.read("#{Settings.json}/inventory/statistical_codes.json"))
  end

  def pull_instance_note_types
    hash = @@folio_request.get_cql('/instance-note-types', "source='local'")
    trim_hash(hash, 'instanceNoteTypes')
    hash.to_json
  end

  def instance_note_types_json
    JSON.parse(File.read("#{Settings.json}/inventory/instance_note_types.json"))
  end

  def instance_note_types_post(obj)
    @@folio_request.post('/instance-note-types', obj.to_json)
  end

  def pull_copycat_profiles
    hash = @@folio_request.get('/copycat/profiles')
    trim_hash(hash, 'profiles')
    hash.to_json
  end

  def copycat_profiles_json
    JSON.parse(File.read("#{Settings.json}/inventory/copycat_profiles.json"))
  end

  def copycat_profiles_post(obj)
    @@folio_request.post('/copycat/profiles', obj.to_json)
  end
end
