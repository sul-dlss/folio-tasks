# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate fiscal year methods used by finance_settings rake tasks
module FiscalYearHelpers
  include FolioRequestHelper
  def fiscal_years_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/fiscal-years.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def fiscal_years_hash(obj)
    acq_unit_ids = acq_unit_id_list(obj['acqUnit_name'])
    obj['acqUnitIds'] = acq_unit_ids unless acq_unit_ids&.empty?
    obj.delete('acqUnit_name')

    obj
  end

  def fiscal_year_id(code)
    response = @@folio_request.get_cql('/finance/fiscal-years', "code==#{code}")['fiscalYears']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def fiscal_years_delete(id)
    @@folio_request.delete("/finance/fiscal-years/#{id}")
  end

  def fiscal_years_post(obj)
    @@folio_request.post('/finance/fiscal-years', obj.to_json)
  end
end
