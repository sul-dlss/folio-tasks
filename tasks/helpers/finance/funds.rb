# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate fund methods used by finance_settings rake tasks
module FundHelpers
  include FolioRequestHelper

  def funds_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/funds.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def funds_hash(obj)
    ledger = ledger_id(obj['ledgerCode'])

    new_obj = { 'fund' => {
      'name' => obj['fundName'],
      'code' => obj['fundId'],
      'externalAccountNo' => obj['externalAccountNo'],
      'fundStatus' => 'Active',
      'ledgerId' => ledger
    } }
    new_obj['fund'].store('fundTypeId', fund_type_id(obj['fundType'])) unless obj['fundType'].nil?
    new_obj['fund'].store('acqUnitIds', acq_unit_id_list(obj['acqUnit_name'])) unless obj['acqUnit_name'].nil?
    new_obj.store('groupIds', [finance_group_id(obj['groupCode'])]) unless obj['groupCode'].nil?

    new_obj
  end

  def fund_id(code)
    response = @@folio_request.get_cql('/finance/funds', "code==#{code}")['funds']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def funds_delete(id)
    @@folio_request.delete("/finance/funds/#{id}")
  end

  def funds_post(obj)
    @@folio_request.post('/finance/funds', obj.to_json)
  end
end
