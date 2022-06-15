# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'finance settings rake tasks' do
  let(:update_budgets_task) { Rake.application.invoke_task 'acquisitions:update_budgets' }
  let(:acq_units) { Uuids.acq_units }
  let(:allocate_budgets_task) { Rake.application.invoke_task 'acquisitions:allocate_budgets' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/finance/fund-types')
    stub_request(:get, 'http://example.com/finance/fund-types')
      .with(query: hash_including)
      .to_return(body: '{ "fundTypes": [{ "id": "abc-123", "name": "Dummy" }] }')

    stub_request(:post, 'http://example.com/finance/expense-classes')
    stub_request(:get, 'http://example.com/finance/expense-classes')
      .with(query: hash_including)
      .to_return(body: '{ "expenseClasses": [{ "id": "exp-123", "code": "12345" },
                                             { "id": "exp-456", "code": "67890" }] }')

    stub_request(:get, 'http://example.com/acquisitions-units-storage/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123", "name": "acq_unit1" },
                                                { "id": "acq-456", "name": "acq_unit2" },
                                                { "id": "acq-123", "name": "SUL" }] }')

    stub_request(:post, 'http://example.com/finance/fiscal-years')
    stub_request(:get, 'http://example.com/finance/fiscal-years')
      .with(query: hash_including)
      .to_return(body: '{ "fiscalYears": [{ "id": "abc-123", "code": "FYCODE" }] }')

    stub_request(:post, 'http://example.com/finance/ledgers')
    stub_request(:get, 'http://example.com/finance/ledgers')
      .with(query: hash_including)
      .to_return(body: '{ "ledgers": [{ "id": "abc-123", "code": "LEDGER_2020" },
                                      { "id": "abc-123", "code": "BUS" },
                                      { "id": "abc-123", "code": "LAW" },
                                      { "id": "abc-123", "code": "SUL" }] }')

    stub_request(:post, 'http://example.com/finance/groups')
    stub_request(:get, 'http://example.com/finance/groups')
      .with(query: hash_including)
      .to_return(body: '{ "groups": [{ "id": "abc-123", "code": "DUMMY" }] }')

    stub_request(:post, 'http://example.com/finance/funds')
    stub_request(:get, 'http://example.com/finance/funds')
      .with(query: hash_including)
      .to_return(body: '{ "funds": [{ "id": "abc-123", "code": "FUND_NAME-SUL" }] }')

    stub_request(:get, 'http://example.com/finance/budgets')
      .with(query: hash_including)
      .to_return(body: '{ "budgets": [{ "id": "xyz-123", "name": "FUND_NAME-SUL-FYCODE" }] }')

    stub_request(:put, 'http://example.com/finance/budgets/xyz-123')

    stub_request(:post, 'http://example.com/finance/allocations')
  end

  context 'when updating budgets' do
    let(:budgets_csv) { update_budgets_task.send(:budgets_csv) }
    let(:uuid_maps) do
      [Uuids.bus_funds, Uuids.law_funds, Uuids.sul_funds, Uuids.acq_units, Uuids.fiscal_years, Uuids.expense_classes]
    end

    it 'creates the hash key and value for budget name' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0],
                                      uuid_maps)['name']).to eq 'FUND_NAME-SUL-FYCODE'
    end

    it 'creates the hash key and value for budgetStatus' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['budgetStatus']).to eq 'Active'
    end

    it 'creates the hash key and value for budget allocated' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['allocated']).to eq '1000'
    end

    it 'creates the hash key and value for fundId' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['fundId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for fiscalYearId' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['fiscalYearId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for acqUnitIds' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['acqUnitIds']).to include 'acq-123'
    end

    it 'creates the hash key and value for statusExpenseClasses' do
      expect(update_budgets_task.send(:budgets_hash,
                                      budgets_csv[0], uuid_maps)['statusExpenseClasses'])
        .to include(a_hash_including('expenseClassId' => 'exp-123'))
    end
  end

  context 'when allocating budgets' do
    let(:allocations_tsv) { allocate_budgets_task.send(:allocations_tsv) }
    let(:uuid_maps) { [Uuids.bus_funds, Uuids.law_funds, Uuids.sul_funds, Uuids.fiscal_years] }

    it 'creates hash key and value for fiscalYearId' do
      expect(allocate_budgets_task.send(:budget_allocations_hash, allocations_tsv[0],
                                        uuid_maps)['fiscalYearId']).to eq 'abc-123'
    end

    it 'creates hash key and value for toFundId' do
      expect(allocate_budgets_task.send(:budget_allocations_hash, allocations_tsv[0],
                                        uuid_maps)['toFundId']).to eq 'abc-123'
    end

    it 'does not have an acqUnit_name key' do
      expect(allocate_budgets_task.send(:budget_allocations_hash, allocations_tsv[0],
                                        uuid_maps)).not_to have_key 'acqUnit_name'
    end

    it 'does not have a fundCode key' do
      expect(allocate_budgets_task.send(:budget_allocations_hash, allocations_tsv[0],
                                        uuid_maps)).not_to have_key 'fundCode'
    end

    it 'does not have a fiscalYearCode key' do
      expect(allocate_budgets_task.send(:budget_allocations_hash, allocations_tsv[0],
                                        uuid_maps)).not_to have_key 'fiscalYearCode'
    end
  end
end
