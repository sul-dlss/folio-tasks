# frozen_string_literal: true

require 'csv'
require 'require_all'
require_relative '../../lib/folio_request'
require_relative '../helpers/acq_units'
require_rel '../helpers/finance'

include BudgetHelpers, FundHelpers, FinanceGroupHelpers, LedgerHelpers, FiscalYearHelpers,
        ExpenseClassHelpers, FundTypeHelpers
include AcquisitionsUnitsTaskHelpers

desc 'load fund types into folio'
task :load_fund_types do
  fund_types_csv.each do |obj|
    fund_types_post(obj)
  end
end

desc 'load expense classes into folio'
task :load_expense_classes do
  expense_classes_csv.each do |obj|
    expense_classes_post(obj)
  end
end

desc 'load fiscal years into folio'
task :load_fiscal_years do
  fiscal_years_csv.each do |obj|
    hash = fiscal_years_hash(obj)
    fiscal_years_post(hash)
  end
end

desc 'load ledgers into folio'
task :load_ledgers do
  ledgers_csv.each do |obj|
    hash = ledgers_hash(obj)
    ledgers_post(hash)
  end
end

desc 'load finance groups into folio'
task :load_finance_groups do
  finance_groups_csv.each do |obj|
    hash = finance_groups_hash(obj)
    finance_groups_post(hash)
  end
end

desc 'load funds into folio'
task :load_funds do
  funds_csv.each do |obj|
    hash = funds_hash(obj)
    funds_post(hash)
  end
end

desc 'load budgets into folio'
task :load_budgets do
  budgets_csv.each do |obj|
    hash = budgets_hash(obj)
    budgets_post(hash)
  end
end
