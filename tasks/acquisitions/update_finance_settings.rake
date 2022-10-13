# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/finance'
require_relative '../helpers/uuids/acquisitions'

namespace :acquisitions do
  include AcquisitionsUuidsHelpers, BudgetHelpers, TransactionHelpers

  desc 'update budgets in folio'
  task :update_budgets do
    uuid_maps = [AcquisitionsUuidsHelpers.bus_funds, AcquisitionsUuidsHelpers.law_funds,
                 AcquisitionsUuidsHelpers.sul_funds, AcquisitionsUuidsHelpers.acq_units,
                 AcquisitionsUuidsHelpers.fiscal_years, AcquisitionsUuidsHelpers.expense_classes]
    budgets = AcquisitionsUuidsHelpers.budgets
    budgets_csv.each do |obj|
      hash = budgets_hash(obj, uuid_maps)
      id = budget_id(hash['name'], budgets)
      budgets_put(id, hash)
    end
  end

  desc 'allocate budgets'
  task :allocate_budgets do
    uuid_maps = [AcquisitionsUuidsHelpers.bus_funds, AcquisitionsUuidsHelpers.law_funds,
                 AcquisitionsUuidsHelpers.sul_funds, AcquisitionsUuidsHelpers.fiscal_years]
    allocations_tsv.each do |obj|
      hash = budget_allocations_hash(obj, uuid_maps)
      allocations_post(hash)
    end
  end

  desc 'update expense classes in folio'
  task :update_expense_classes do
    expense_classes = AcquisitionsUuidsHelpers.expense_classes
    expense_classes_csv.each do |obj|
      id = expense_class_id(obj['code'], expense_classes)
      puts "updating expense class #{obj['code']}"
      expense_class_put(id, obj)
    end
  end

  desc 'update funds in folio'
  task :update_funds do
    uuid_maps = [AcquisitionsUuidsHelpers.ledgers, AcquisitionsUuidsHelpers.acq_units,
                 AcquisitionsUuidsHelpers.finance_groups, AcquisitionsUuidsHelpers.fund_types]
    bus_funds = AcquisitionsUuidsHelpers.bus_funds
    law_funds = AcquisitionsUuidsHelpers.law_funds
    sul_funds = AcquisitionsUuidsHelpers.sul_funds
    funds_csv.each do |obj|
      hash = funds_hash(obj, uuid_maps)
      id = fund_id(obj['fundCode'], bus_funds, law_funds, sul_funds, obj['acqUnit_name'])
      puts "updating fund #{obj['fundCode']}"
      funds_put(id, hash)
    end
  end
end
