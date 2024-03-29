# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate fiscal year methods used by finance_settings rake tasks
module FiscalYearHelpers
  include FolioRequestHelper
  def fiscal_years_csv
    CSV.parse(File.open("#{Settings.tsv}/finance/fiscal-years.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def fiscal_years_hash(obj, acq_units_uuids)
    acq_unit_ids = acq_unit_id_list(obj['acqUnit_name'], acq_units_uuids)
    obj['acqUnitIds'] = acq_unit_ids unless acq_unit_ids&.empty?
    obj.delete('acqUnit_name')

    obj
  end

  def fiscal_years_delete(id)
    @@folio_request.delete("/finance/fiscal-years/#{id}")
  end

  def fiscal_years_post(obj)
    @@folio_request.post('/finance/fiscal-years', obj.to_json)
  end
end
