# frozen_string_literal: true

require 'csv'
require 'require_all'
require_relative '../helpers/acq_units'
require_relative '../helpers/uuids/acquisitions'
require_rel '../helpers/finance'

namespace :acquisitions do
  include BudgetHelpers, FundHelpers, FinanceGroupHelpers, LedgerHelpers, FiscalYearHelpers,
          ExpenseClassHelpers, FundTypeHelpers, AcquisitionsUnitsTaskHelpers, AcquisitionsUuidsHelpers

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
    acq_units = AcquisitionsUuidsHelpers.acq_units
    fiscal_years_csv.each do |obj|
      hash = fiscal_years_hash(obj, acq_units)
      fiscal_years_post(hash)
    end
  end

  desc 'load ledgers into folio'
  task :load_ledgers do
    acq_units = AcquisitionsUuidsHelpers.acq_units
    fiscal_years = AcquisitionsUuidsHelpers.fiscal_years
    ledgers_csv.each do |obj|
      hash = ledgers_hash(obj, fiscal_years, acq_units)
      ledgers_post(hash)
    end
  end

  desc 'load finance groups into folio'
  task :load_finance_groups do
    acq_units = AcquisitionsUuidsHelpers.acq_units
    finance_groups_csv.each do |obj|
      hash = finance_groups_hash(obj, acq_units)
      finance_groups_post(hash)
    end
  end

  desc 'load funds into folio'
  task :load_funds do
    uuid_maps = [AcquisitionsUuidsHelpers.ledgers, AcquisitionsUuidsHelpers.acq_units,
                 AcquisitionsUuidsHelpers.finance_groups, AcquisitionsUuidsHelpers.fund_types]
    funds_csv.each do |obj|
      hash = funds_hash(obj, uuid_maps)
      funds_post(hash)
    end
  end

  desc 'load budgets into folio'
  task :load_budgets do
    uuid_maps = [AcquisitionsUuidsHelpers.bus_funds, AcquisitionsUuidsHelpers.law_funds,
                 AcquisitionsUuidsHelpers.sul_funds, AcquisitionsUuidsHelpers.acq_units,
                 AcquisitionsUuidsHelpers.fiscal_years, AcquisitionsUuidsHelpers.expense_classes]
    budgets_csv.each do |obj|
      hash = budgets_hash(obj, uuid_maps)
      budgets_post(hash)
    end
  end
end
