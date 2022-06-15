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
end
