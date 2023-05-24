# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate fund_type methods used by finance_settings rake tasks
module FundTypeHelpers
  include FolioRequestHelper

  def fund_types_csv
    CSV.parse(File.open("#{Settings.tsv}/finance/fund-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def fund_types_delete(id)
    @@folio_request.delete("/finance/fund-types/#{id}")
  end

  def fund_types_post(obj)
    @@folio_request.post('/finance/fund-types', obj.to_json)
  end
end
