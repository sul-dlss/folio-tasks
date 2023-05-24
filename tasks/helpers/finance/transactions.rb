# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate transaction methods used by finance_settings rake tasks
module TransactionHelpers
  include FolioRequestHelper

  def allocations_tsv
    CSV.parse(File.open("#{Settings.tsv}/finance/budget_allocations.tsv"), headers: true,
                                                                                col_sep: "\t").map(&:to_h)
  end

  def budget_allocations_hash(obj, uuid_maps)
    bus_funds, law_funds, sul_funds, fiscal_years = uuid_maps

    obj['fiscalYearId'] = fiscal_years.fetch(obj['fiscalYearCode'], nil)
    obj['toFundId'] = fund_id(obj['fundCode'], bus_funds, law_funds, sul_funds, obj['acqUnit_name'])
    obj['amount'] = obj['amount'].to_i
    obj.delete('acqUnit_name')
    obj.delete('fundCode')
    obj.delete('fiscalYearCode')

    obj.compact
  end

  def allocations_post(obj)
    @@folio_request.post('/finance/allocations', obj.to_json)
  end
end
