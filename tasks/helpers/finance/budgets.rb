# frozen_string_literal: true

# Module to encapsulate budget methods used by finance_settings rake tasks
module BudgetHelpers
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
    response = FolioRequest.new.get_cql('/finance/budgets',
                                        "fundId==#{fund_id}&fiscalYearId=#{fy_id}")['budgets']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def budgets_delete(id)
    FolioRequest.new.delete("/finance/budgets/#{id}")
  end

  def budgets_post(obj)
    FolioRequest.new.post('/finance/budgets', obj.to_json)
  end

  def budgets_put(id, obj)
    FolioRequest.new.put("/finance/budgets/#{id}", obj.to_json)
  end
end
