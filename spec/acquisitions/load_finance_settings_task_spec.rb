# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'finance settings rake tasks' do
  let(:load_fund_types_task) { Rake.application.invoke_task 'load_fund_types' }
  let(:load_expense_classes_task) { Rake.application.invoke_task 'load_expense_classes' }
  let(:load_fiscal_years_task) { Rake.application.invoke_task 'load_fiscal_years' }
  let(:load_ledgers_task) { Rake.application.invoke_task 'load_ledgers' }
  let(:load_finance_groups_task) { Rake.application.invoke_task 'load_finance_groups' }
  let(:load_funds_task) { Rake.application.invoke_task 'load_funds' }
  let(:load_budgets_task) { Rake.application.invoke_task 'load_budgets' }
  let(:load_acq_units_task) { Rake.application.invoke_task 'load_acq_units' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/finance/fund-types')
    stub_request(:get, 'http://example.com/finance/fund-types')
      .with(query: hash_including)
      .to_return(body: '{ "fundTypes": [{ "id": "abc-123" }] }')

    stub_request(:post, 'http://example.com/finance/expense-classes')
    stub_request(:get, 'http://example.com/finance/expense-classes')
      .with(query: hash_including)
      .to_return(body: '{ "expenseClasses": [{ "id": "exp-123" }] }')

    stub_request(:post, 'http://example.com/acquisitions-units-storage/units')
    stub_request(:get, 'http://example.com/acquisitions-units-storage/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123" }] }')

    stub_request(:post, 'http://example.com/finance/fiscal-years')
    stub_request(:get, 'http://example.com/finance/fiscal-years')
      .with(query: hash_including)
      .to_return(body: '{ "fiscalYears": [{ "id": "abc-123" }] }')

    stub_request(:post, 'http://example.com/finance/ledgers')
    stub_request(:get, 'http://example.com/finance/ledgers')
      .with(query: hash_including)
      .to_return(body: '{ "ledgers": [{ "id": "abc-123" }] }')

    stub_request(:post, 'http://example.com/finance/groups')
    stub_request(:get, 'http://example.com/finance/groups')
      .with(query: hash_including)
      .to_return(body: '{ "groups": [{ "id": "abc-123" }] }')

    stub_request(:post, 'http://example.com/finance/funds')
    stub_request(:get, 'http://example.com/finance/funds')
      .with(query: hash_including)
      .to_return(body: '{ "funds": [{ "id": "abc-123" }] }')

    stub_request(:post, 'http://example.com/finance/budgets')
  end

  context 'when loading fund types' do
    it 'creates the hash key and value for fund name' do
      expect(load_fund_types_task.send(:fund_types_csv)[0]['name']).to eq 'Dummy'
    end
  end

  context 'when loading expense classes' do
    it 'creates the hash key and value for expense class name' do
      expect(load_expense_classes_task.send(:expense_classes_csv)[0]['name']).to eq 'Electronic'
    end

    it 'creates the hash key and value for expense class code' do
      expect(load_expense_classes_task.send(:expense_classes_csv)[0]['code']).to eq 'Elec'
    end

    it 'creates the hash key and value for expense class external account number extension' do
      expect(load_expense_classes_task.send(:expense_classes_csv)[0]['externalAccountNumberExt']).to eq '12345'
    end
  end

  context 'when loading fiscal years' do
    it 'creates the hash key and value for fiscal year name' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0])['name']).to eq 'Name 2020'
    end

    it 'creates the hash key and value for fiscal year code' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0])['code']).to eq 'NAME2020'
    end

    it 'creates the hash key and value for fiscal periodStart' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0])['periodStart']).to eq '2019-09-01'
    end

    it 'creates the hash key and value for fiscal periodEnd' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0])['periodEnd']).to eq '2020-08-31'
    end

    it 'creates the hash key and array value for associated acquisitions units' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0])['acqUnitIds']).to include 'acq-123'
    end

    it 'deletes the hash key and value for acqUnit_name' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0])).not_to have_key 'acqUnit_name'
    end
  end

  context 'when loading finance ledgers' do
    let(:ledger_csv) { load_ledgers_task.send(:ledgers_csv) }

    it 'creates the hash key and value for ledger name' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0])['name']).to eq 'Ledger entry'
    end

    it 'creates the hash key and value for ledger code' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0])['code']).to eq 'CODE'
    end

    it 'creates the hash key and value for ledger fiscalYearOneId' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0])['fiscalYearOneId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for ledgerStatus' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0])['ledgerStatus']).to eq 'Active'
    end

    it 'deletes the hash key and value for fiscalYearCode' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0])).not_to have_key 'fiscalYearCode'
    end

    it 'creates the hash key and array value for associated acquisitions units' do
      expect(load_fiscal_years_task.send(:ledgers_hash, ledger_csv[0])['acqUnitIds']).to include 'acq-123'
    end

    it 'deletes the hash key and value for acqUnit_name' do
      expect(load_fiscal_years_task.send(:ledgers_hash, ledger_csv[0])).not_to have_key 'acqUnit_name'
    end
  end

  context 'when loading finance groups' do
    it 'creates the hash key and value for finance group name' do
      expect(load_finance_groups_task.send(:finance_groups_hash, finance_groups_csv[0])['name']).to eq 'Dummy'
    end

    it 'creates the hash key and value for finance group code' do
      expect(load_finance_groups_task.send(:finance_groups_hash, finance_groups_csv[0])['code']).to eq 'DUMMY'
    end

    it 'creates the hash key and value for finance group status' do
      expect(load_finance_groups_task.send(:finance_groups_hash, finance_groups_csv[0])['status']).to eq 'Active'
    end

    it 'creates the hash key and array value for associated acquisitions units' do
      expect(load_finance_groups_task.send(:finance_groups_hash,
                                           finance_groups_csv[0])['acqUnitIds']).to include 'acq-123'
    end

    it 'deletes the hash key and value for acqUnit_name' do
      expect(load_finance_groups_task.send(:finance_groups_hash, finance_groups_csv[0])).not_to have_key 'acqUnit_name'
    end
  end

  context 'when loading funds' do
    let(:funds_csv) { load_ledgers_task.send(:funds_csv) }
    let(:fund) { load_funds_task.send(:funds_hash, funds_csv[0])['fund'] }

    it 'creates the fund hash' do
      expect(fund).to be_kind_of(Hash)
    end

    it 'creates the hash key and value for fund name' do
      expect(fund['name']).to eq 'FUND_NAME'
    end

    it 'creates the hash key and value for fund code' do
      expect(fund['code']).to eq 'FUND_NAME'
    end

    it 'creates the hash key and value for externalAccountNo' do
      expect(fund['externalAccountNo']).to eq '1234567-890-AABBC'
    end

    it 'creates the hash key and value for fundStatus' do
      expect(fund['fundStatus']).to eq 'Active'
    end

    it 'creates the hash key and value for fundTypeId' do
      expect(fund['fundTypeId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for ledgerId' do
      expect(fund['ledgerId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for acqUnitIds' do
      expect(fund['acqUnitIds']).to include 'acq-123'
    end

    it 'creates the hash key and value for groupIds' do
      expect(load_funds_task.send(:funds_hash, funds_csv[0])['groupIds']).to eq ['abc-123']
    end
  end

  context 'when loading budgets' do
    let(:budgets_csv) { load_budgets_task.send(:budgets_csv) }

    it 'creates the hash key and value for budget name' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0])['name']).to eq '1234567-890-AABCD-FY2020'
    end

    it 'creates the hash key and value for budgetStatus' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0])['budgetStatus']).to eq 'Active'
    end

    it 'creates the hash key and value for budget allocated' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0])['allocated']).to eq '1000'
    end

    it 'creates the hash key and value for fundId' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0])['fundId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for fiscalYearId' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0])['fiscalYearId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for acqUnitIds' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0])['acqUnitIds']).to include 'acq-123'
    end

    it 'creates the hash key and value for statusExpenseClasses' do
      expect(load_budgets_task.send(:budgets_hash,
                                    budgets_csv[0])['statusExpenseClasses'])
        .to include(a_hash_including('expenseClassId' => 'exp-123'))
    end
  end
end
