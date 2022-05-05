# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/finance'

namespace :acquisitions do
  include BudgetHelpers

  desc 'update budgets in folio'
  task :update_budgets do
    budgets_csv.each do |obj|
      hash = budgets_hash(obj)
      id = budget_id(hash['fundId'], hash['fiscalYearId'])
      budgets_put(id, hash)
    end
  end
end
