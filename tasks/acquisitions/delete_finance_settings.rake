# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/finance'
require_relative '../helpers/uuids/acquisitions'

namespace :acquisitions do
  include BudgetHelpers, FundHelpers, FinanceGroupHelpers, LedgerHelpers, FiscalYearHelpers,
          ExpenseClassHelpers, FundTypeHelpers, AcquisitionsUuidsHelpers

  desc 'delete budgets from folio'
  task :delete_budgets do
    uuid_maps = [AcquisitionsUuidsHelpers.bus_funds, AcquisitionsUuidsHelpers.law_funds,
                 AcquisitionsUuidsHelpers.sul_funds, AcquisitionsUuidsHelpers.acq_units,
                 AcquisitionsUuidsHelpers.fiscal_years, AcquisitionsUuidsHelpers.expense_classes]
    budgets = AcquisitionsUuidsHelpers.budgets
    budgets_csv.each do |obj|
      hash = budgets_hash(obj, uuid_maps)
      id = budget_id(hash['name'], budgets)
      budgets_delete(id)
    end
  end

  desc 'delete funds from folio'
  task :delete_funds do
    bus_funds = AcquisitionsUuidsHelpers.bus_funds
    law_funds = AcquisitionsUuidsHelpers.law_funds
    sul_funds = AcquisitionsUuidsHelpers.sul_funds
    funds_csv.each do |obj|
      id = fund_id(obj['fundId'], bus_funds, law_funds, sul_funds, obj['acqUnit_name'])
      funds_delete(id)
    end
  end

  desc 'delete finance groups from folio'
  task :delete_finance_groups do
    finance_groups = AcquisitionsUuidsHelpers.finance_groups
    finance_groups_csv.each do |obj|
      id = finance_groups.fetch(obj['code'], nil)
      finance_groups_delete(id)
    end
  end

  desc 'delete ledgers from folio'
  task :delete_ledgers do
    ledgers = AcquisitionsUuidsHelpers.ledgers
    ledgers_csv.each do |obj|
      id = ledgers.fetch(obj['code'], nil)
      ledgers_delete(id)
    end
  end

  desc 'delete fiscal years from folio'
  task :delete_fiscal_years do
    fiscal_years = AcquisitionsUuidsHelpers.fiscal_years
    fiscal_years_csv.each do |obj|
      id = fiscal_years.fetch(obj['code'], nil)
      fiscal_years_delete(id)
    end
  end

  desc 'delete expense classes from folio'
  task :delete_expense_classes do
    expense_classes = AcquisitionsUuidsHelpers.expense_classes
    expense_classes_csv.each do |obj|
      id = expense_classes.fetch(obj['code'], nil)
      expense_class_delete(id)
    end
  end

  desc 'delete fund types from folio'
  task :delete_fund_types do
    fund_types = AcquisitionsUuidsHelpers.fund_types
    fund_types_csv.each do |obj|
      id = fund_types.fetch(obj['name'], nil)
      fund_types_delete(id)
    end
  end
end
