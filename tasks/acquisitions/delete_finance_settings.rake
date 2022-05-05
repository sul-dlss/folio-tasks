# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/finance'

namespace :acquisitions do
  include BudgetHelpers, FundHelpers, FinanceGroupHelpers, LedgerHelpers, FiscalYearHelpers,
          ExpenseClassHelpers, FundTypeHelpers

  desc 'delete budgets from folio'
  task :delete_budgets do
    budgets_csv.each do |obj|
      hash = budgets_hash(obj)
      id = budget_id(hash['fundId'], hash['fiscalYearId'])
      budgets_delete(id)
    end
  end

  desc 'delete funds from folio'
  task :delete_funds do
    funds_csv.each do |obj|
      id = fund_id(obj['fundId'])
      funds_delete(id)
    end
  end

  desc 'delete finance groups from folio'
  task :delete_finance_groups do
    finance_groups_csv.each do |obj|
      id = finance_group_id(obj['code'])
      finance_groups_delete(id)
    end
  end

  desc 'delete ledgers from folio'
  task :delete_ledgers do
    ledgers_csv.each do |obj|
      id = ledger_id(obj['code'])
      ledgers_delete(id)
    end
  end

  desc 'delete fiscal years from folio'
  task :delete_fiscal_years do
    fiscal_years_csv.each do |obj|
      id = fiscal_year_id(obj['code'])
      fiscal_years_delete(id)
    end
  end

  desc 'delete expense classes from folio'
  task :delete_expense_classes do
    expense_classes_csv.each do |obj|
      id = expense_class_id(obj['code'])
      expense_class_delete(id)
    end
  end

  desc 'delete fund types from folio'
  task :delete_fund_types do
    fund_types_csv.each do |obj|
      id = fund_type_id(obj['name'])
      fund_types_delete(id)
    end
  end
end
