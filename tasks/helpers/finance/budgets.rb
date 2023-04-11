# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate budget methods used by finance_settings rake tasks
module BudgetHelpers
  include FolioRequestHelper

  def budgets_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/budgets.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def budgets_hash(obj, uuid_maps)
    bus_funds, law_funds, sul_funds, acq_units, fiscal_years, expense_classes = uuid_maps
    name = budget_name(obj)
    new_obj = { 'id' => determine_budget_uuid(name, Settings.okapi.url.to_s),
                'name' => name,
                'budgetStatus' => 'Active',
                'allocated' => obj['allocated'].to_i,
                'fundId' => fund_id(obj['fundCode'], bus_funds, law_funds, sul_funds, obj['acqUnit_name']),
                'fiscalYearId' => fiscal_years.fetch(obj['fiscalYearCode'], nil) }
    new_obj.store('allowableExpenditure', obj['allowableExpenditure'].to_i) unless obj['allowableExpenditure'].nil?
    new_obj.store('acqUnitIds', acq_unit_id_list(obj['acqUnit_name'], acq_units)) unless obj['acqUnit_name'].nil?
    unless obj['expenseClass_code'].nil?
      new_obj.store('statusExpenseClasses', expense_class_id_list(obj['expenseClass_code'], expense_classes))
    end

    new_obj.compact
  end

  def determine_budget_uuid(legacy_identifier, okapi_url)
    FolioUuid.new.generate(okapi_url, 'budgets', legacy_identifier)
  end

  def budget_name(obj)
    "#{obj['fundCode']}-#{obj['fiscalYearCode']}"
  end

  def budget_id(name, budgets_hash)
    budgets_hash.fetch(name, nil)
  end

  def budgets_delete(id)
    @@folio_request.delete("/finance/budgets/#{id}")
  end

  def budgets_post(obj)
    @@folio_request.post('/finance/budgets', obj.to_json)
  end
end
