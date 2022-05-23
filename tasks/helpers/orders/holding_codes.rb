# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate holding code to location UUID map used by orders rake tasks
module HoldingCodeHelpers
  include FolioRequestHelper

  def hldg_codes_tsv(file)
    CSV.parse(File.open("#{Settings.tsv}/#{file}"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def hldg_code_map(file, locations_hash)
    map = {}
    hldg_codes_tsv(file).each do |row|
      map[row['code']] = location_uuid(row['folio_code'], locations_hash)
    end
    map
  end

  def location_uuid(code, locations_hash)
    locations_hash.fetch(code, nil)
  end
end
