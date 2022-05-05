# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate budget methods used by finance_settings rake tasks
module BudgetHelpers
  include FolioRequestHelper

  def budgets_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/budgets.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def budgets_hash(obj)
    fund_id = fund_id(obj['fundCode'])
    fy_id = fiscal_year_id(obj['fiscalYearCode'])

    new_obj = { 'name' => "#{obj['fundCode']}-#{obj['fiscalYearCode']}",
                'budgetStatus' => 'Active',
                'allocated' => obj['allocated'],
                'fundId' => fund_id,
                'fiscalYearId' => fy_id }
    new_obj.store('acqUnitIds', acq_unit_id_list(obj['acqUnit_name'])) unless obj['acqUnit_name'].nil?
    unless obj['expenseClass_code'].nil?
      new_obj.store('statusExpenseClasses',
                    expense_class_id_list(obj['expenseClass_code']))
    end

    new_obj
  end

  def budget_id(fund_id, fy_id)
    response = @@folio_request.get_cql('/finance/budgets',
                                       "fundId==#{fund_id}&fiscalYearId=#{fy_id}")['budgets']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def budgets_delete(id)
    @@folio_request.delete("/finance/budgets/#{id}")
  end

  def budgets_post(obj)
    @@folio_request.post('/finance/budgets', obj.to_json)
  end

  def budgets_put(id, obj)
    @@folio_request.put("/finance/budgets/#{id}", obj.to_json)
  end
end
