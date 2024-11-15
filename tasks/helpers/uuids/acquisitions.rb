# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate UUID methods used by acquisitions rake tasks
module AcquisitionsUuidsHelpers
  include FolioRequestHelper

  def acq_units
    acq_unit_hash = {}
    @@folio_request.get('/acquisitions-units/units')['acquisitionsUnits'].each do |obj|
      acq_unit_hash[obj['name']] = obj['id']
    end
    acq_unit_hash
  end

  def acq_unit_membership
    membership_hash = {}
    @@folio_request.get('/acquisitions-units/memberships?limit=10000')['acquisitionsUnitMemberships'].each do |obj|
      key = obj['acquisitionsUnitId'] + obj['userId']
      membership_hash[key] = obj['id']
    end
    membership_hash
  end

  def acquisition_methods
    acq_method_hash = {}
    @@folio_request.get('/orders/acquisition-methods?limit=50')['acquisitionMethods'].each do |obj|
      acq_method_hash[obj['value']] = obj['id']
    end
    acq_method_hash
  end

  def budgets
    budgets_hash = {}
    @@folio_request.get('/finance/budgets?limit=999')['budgets'].each do |obj|
      budgets_hash[obj['name']] = obj['id']
    end
    budgets_hash
  end

  def expense_classes
    expense_class_hash = {}
    @@folio_request.get('/finance/expense-classes?limit=99')['expenseClasses'].each do |obj|
      expense_class_hash[obj['code']] = obj['id']
    end
    expense_class_hash
  end

  def finance_groups
    finance_groups_hash = {}
    @@folio_request.get('/finance/groups?limit=99')['groups'].each do |obj|
      finance_groups_hash[obj['code']] = obj['id']
    end
    finance_groups_hash
  end

  def fiscal_years
    fy_hash = {}
    @@folio_request.get('/finance/fiscal-years?limit=99')['fiscalYears'].each do |obj|
      fy_hash[obj['code']] = obj['id']
    end
    fy_hash
  end

  def bus_funds
    funds_hash = {}
    ledger_id = ledgers.fetch('BUS')
    @@folio_request.get("/finance/funds?limit=999&query=ledgerId=#{ledger_id}")['funds'].each do |obj|
      funds_hash[obj['code']] = obj['id']
    end
    funds_hash
  end

  def law_funds
    funds_hash = {}
    ledger_id = ledgers.fetch('LAW')
    @@folio_request.get("/finance/funds?limit=999&query=ledgerId=#{ledger_id}")['funds'].each do |obj|
      funds_hash[obj['code']] = obj['id']
    end
    funds_hash
  end

  def sul_funds
    funds_hash = {}
    ledger_id = ledgers.fetch('SUL')
    @@folio_request.get("/finance/funds?limit=999&query=ledgerId=#{ledger_id}")['funds'].each do |obj|
      funds_hash[obj['code']] = obj['id']
    end
    funds_hash
  end

  def fund_types
    fund_types_hash = {}
    @@folio_request.get('/finance/fund-types?limit=99')['fundTypes'].each do |obj|
      fund_types_hash[obj['name']] = obj['id']
    end
    fund_types_hash
  end

  def ledgers
    ledgers_hash = {}
    @@folio_request.get('/finance/ledgers')['ledgers'].each do |obj|
      ledgers_hash[obj['code']] = obj['id']
    end
    ledgers_hash
  end

  def orders
    orders_hash = {}
    @@folio_request.get('/orders/composite-orders?limit=99999')['purchaseOrders'].each do |obj|
      orders_hash[obj['poNumber']] = obj['id']
    end
    orders_hash
  end

  def organization_categories
    org_categories_hash = {}
    @@folio_request.get('/organizations-storage/categories?limit=100')['categories'].each do |obj|
      org_categories_hash[obj['value']] = obj['id']
    end
    org_categories_hash
  end

  # rubocop: disable Layout/LineLength
  def law_organizations
    organizations_hash = {}
    acq_id = acq_units.fetch('Law')
    @@folio_request.get("/organizations/organizations?limit=3000&query=acqUnitIds=#{acq_id}")['organizations'].each do |obj|
      organizations_hash[obj['code']] = obj['id']
    end
    organizations_hash
  end

  def sul_organizations
    organizations_hash = {}
    acq_id = acq_units.fetch('SUL')
    @@folio_request.get("/organizations/organizations?limit=3000&query=acqUnitIds=#{acq_id}")['organizations'].each do |obj|
      organizations_hash[obj['code']] = obj['id']
    end
    organizations_hash
  end
  # rubocop: enable Layout/LineLength
end
