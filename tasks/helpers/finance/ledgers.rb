# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate methods used by finance_settings rake tasks
module LedgerHelpers
  include FolioRequestHelper

  def ledgers_csv
    CSV.parse(File.open("#{Settings.tsv}/finance/ledgers.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def ledgers_hash(obj, fiscal_years, acq_units_uuids)
    fiscal_year_code = fiscal_years.fetch(obj['fiscalYearCode'], nil)
    obj['fiscalYearOneId'] = fiscal_year_code
    obj.delete('fiscalYearCode')

    acq_unit_ids = acq_unit_id_list(obj['acqUnit_name'], acq_units_uuids)
    obj['acqUnitIds'] = acq_unit_ids unless acq_unit_ids&.empty?
    obj.delete('acqUnit_name')

    obj
  end

  def ledgers_delete(id)
    @@folio_request.delete("/finance/ledgers/#{id}")
  end

  def ledgers_post(obj)
    @@folio_request.post('/finance/ledgers', obj.to_json)
  end
end
