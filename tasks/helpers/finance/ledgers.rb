# frozen_string_literal: true

# Module to encapsulate methods used by finance_settings rake tasks
module LedgerHelpers
  def ledgers_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/ledgers.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def ledgers_hash(obj)
    fiscal_year_code = fiscal_year_id(obj['fiscalYearCode'])
    obj['fiscalYearOneId'] = fiscal_year_code
    obj.delete('fiscalYearCode')

    acq_unit_ids = acq_unit_id_list(obj['acqUnit_name'])
    obj['acqUnitIds'] = acq_unit_ids unless acq_unit_ids&.empty?
    obj.delete('acqUnit_name')

    obj
  end

  def ledger_id(code)
    response = FolioRequest.new.get_cql('/finance/ledgers', "code==#{code}")['ledgers']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def ledgers_delete(id)
    FolioRequest.new.delete("/finance/ledgers/#{id}")
  end

  def ledgers_post(obj)
    FolioRequest.new.post('/finance/ledgers', obj.to_json)
  end
end
