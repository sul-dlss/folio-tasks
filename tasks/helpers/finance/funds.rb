# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate fund methods used by finance_settings rake tasks
module FundHelpers
  include FolioRequestHelper

  def funds_csv
    CSV.parse(File.open("#{Settings.tsv}/finance/funds.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def funds_hash(obj, uuid_maps)
    ledgers, acq_units, finance_groups, fund_types = uuid_maps

    new_obj = { 'fund' => {
      'name' => obj['fundName'],
      'code' => obj['fundCode'],
      'externalAccountNo' => obj['externalAccountNo'],
      'fundStatus' => 'Active',
      'ledgerId' => ledgers.fetch(obj['ledgerCode'], nil)
    }.compact }
    new_obj['fund'].store('fundTypeId', fund_types.fetch(obj['fundType'], nil)) unless obj['fundType'].nil?
    unless obj['acqUnit_name'].nil?
      new_obj['fund'].store('acqUnitIds', acq_unit_id_list(obj['acqUnit_name'], acq_units))
    end
    new_obj.store('groupIds', [finance_groups.fetch(obj['groupCode'], nil)]) unless obj['groupCode'].nil?

    new_obj
  end

  def fund_id(fund_code, bus_funds, law_funds, sul_funds, acq_unit_name)
    case acq_unit_name
    when 'Business'
      bus_funds.fetch(fund_code, nil)
    when 'Law'
      law_funds.fetch(fund_code, nil)
    when 'SUL'
      sul_funds.fetch(fund_code, nil)
    end
  end

  def funds_delete(id)
    @@folio_request.delete("/finance/funds/#{id}")
  end

  def funds_post(obj)
    @@folio_request.post('/finance/funds', obj.to_json)
  end

  def funds_put(id, obj)
    @@folio_request.put("/finance/funds/#{id}", obj.to_json)
  end
end
