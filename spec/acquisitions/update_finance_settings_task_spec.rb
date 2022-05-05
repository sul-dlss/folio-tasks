# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'finance settings rake tasks' do
  let(:update_budgets_task) { Rake.application.invoke_task 'update_budgets' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/finance/fiscal-years')
      .with(query: hash_including)
      .to_return(body: '{ "fiscalYears": [{ "id": "abc-123" }] }')

    stub_request(:get, 'http://example.com/finance/funds')
      .with(query: hash_including)
      .to_return(body: '{ "funds": [{ "id": "abc-123" }] }')

    stub_request(:post, 'http://example.com/finance/expense-classes')
    stub_request(:get, 'http://example.com/finance/expense-classes')
      .with(query: hash_including)
      .to_return(body: '{ "expenseClasses": [{ "id": "exp-123" }] }')

    stub_request(:post, 'http://example.com/acquisitions-units-storage/units')
    stub_request(:get, 'http://example.com/acquisitions-units-storage/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123" }] }')

    stub_request(:get, 'http://example.com/finance/budgets')
      .with(query: hash_including)
      .to_return(body: '{ "budgets": [{ "id": "xyz-123" }] }')

    stub_request(:put, 'http://example.com/finance/budgets/xyz-123')
  end

  context 'when updating budgets' do
    let(:budgets_csv) { update_budgets_task.send(:budgets_csv) }

    it 'creates the hash key and value for budget name' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0])['name']).to eq '1234567-890-AABCD-FY2020'
    end

    it 'creates the hash key and value for budgetStatus' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0])['budgetStatus']).to eq 'Active'
    end

    it 'creates the hash key and value for budget allocated' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0])['allocated']).to eq '1000'
    end

    it 'creates the hash key and value for fundId' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0])['fundId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for fiscalYearId' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0])['fiscalYearId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for acqUnitIds' do
      expect(update_budgets_task.send(:budgets_hash, budgets_csv[0])['acqUnitIds']).to include 'acq-123'
    end

    it 'creates the hash key and value for statusExpenseClasses' do
      expect(update_budgets_task.send(:budgets_hash,
                                      budgets_csv[0])['statusExpenseClasses'])
        .to include(a_hash_including('expenseClassId' => 'exp-123'))
    end
  end
end
