# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'finance settings rake tasks' do
  let(:load_fund_types_task) { Rake.application.invoke_task 'acquisitions:load_fund_types' }
  let(:load_expense_classes_task) { Rake.application.invoke_task 'acquisitions:load_expense_classes' }
  let(:load_fiscal_years_task) { Rake.application.invoke_task 'acquisitions:load_fiscal_years' }
  let(:load_ledgers_task) { Rake.application.invoke_task 'acquisitions:load_ledgers' }
  let(:load_finance_groups_task) { Rake.application.invoke_task 'acquisitions:load_finance_groups' }
  let(:load_funds_task) { Rake.application.invoke_task 'acquisitions:load_funds' }
  let(:load_budgets_task) { Rake.application.invoke_task 'acquisitions:load_budgets' }
  let(:load_acq_units_task) { Rake.application.invoke_task 'acquisitions:load_acq_units' }
  let(:acq_units) { AcquisitionsUuidsHelpers.acq_units }
  let(:fiscal_years) { AcquisitionsUuidsHelpers.fiscal_years }

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

    stub_request(:get, 'http://example.com/acquisitions-units/units')
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
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0], acq_units)['name']).to eq 'Name 2020'
    end

    it 'creates the hash key and value for fiscal year code' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0], acq_units)['code']).to eq 'NAME2020'
    end

    it 'creates the hash key and value for fiscal periodStart' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0],
                                         acq_units)['periodStart']).to eq '2019-09-01'
    end

    it 'creates the hash key and value for fiscal periodEnd' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0],
                                         acq_units)['periodEnd']).to eq '2020-08-31'
    end

    it 'creates the hash key and array value for associated acquisitions units' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0],
                                         acq_units)['acqUnitIds']).to include 'acq-123'
    end

    it 'deletes the hash key and value for acqUnit_name' do
      expect(load_fiscal_years_task.send(:fiscal_years_hash, fiscal_years_csv[0],
                                         acq_units)).not_to have_key 'acqUnit_name'
    end
  end

  context 'when loading finance ledgers' do
    let(:ledger_csv) { load_ledgers_task.send(:ledgers_csv) }

    it 'creates the hash key and value for ledger name' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0], fiscal_years, acq_units)['name']).to eq 'Ledger entry'
    end

    it 'creates the hash key and value for ledger code' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0], fiscal_years, acq_units)['code']).to eq 'LEDGER_2020'
    end

    it 'creates the hash key and value for ledger fiscalYearOneId' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0], fiscal_years,
                                    acq_units)['fiscalYearOneId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for ledgerStatus' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0], fiscal_years,
                                    acq_units)['ledgerStatus']).to eq 'Active'
    end

    it 'deletes the hash key and value for fiscalYearCode' do
      expect(load_ledgers_task.send(:ledgers_hash, ledger_csv[0], fiscal_years,
                                    acq_units)).not_to have_key 'fiscalYearCode'
    end

    it 'creates the hash key and array value for associated acquisitions units' do
      expect(load_fiscal_years_task.send(:ledgers_hash, ledger_csv[0], fiscal_years,
                                         acq_units)['acqUnitIds']).to include 'acq-123'
    end

    it 'deletes the hash key and value for acqUnit_name' do
      expect(load_fiscal_years_task.send(:ledgers_hash, ledger_csv[0], fiscal_years,
                                         acq_units)).not_to have_key 'acqUnit_name'
    end
  end

  context 'when loading finance groups' do
    it 'creates the hash key and value for finance group name' do
      expect(load_finance_groups_task.send(:finance_groups_hash, finance_groups_csv[0],
                                           acq_units)['name']).to eq 'Dummy'
    end

    it 'creates the hash key and value for finance group code' do
      expect(load_finance_groups_task.send(:finance_groups_hash, finance_groups_csv[0],
                                           acq_units)['code']).to eq 'DUMMY'
    end

    it 'creates the hash key and value for finance group status' do
      expect(load_finance_groups_task.send(:finance_groups_hash, finance_groups_csv[0],
                                           acq_units)['status']).to eq 'Active'
    end

    it 'creates the hash key and array value for associated acquisitions units' do
      expect(load_finance_groups_task.send(:finance_groups_hash,
                                           finance_groups_csv[0], acq_units)['acqUnitIds']).to include 'acq-123'
    end

    it 'deletes the hash key and value for acqUnit_name' do
      expect(load_finance_groups_task.send(:finance_groups_hash, finance_groups_csv[0],
                                           acq_units)).not_to have_key 'acqUnit_name'
    end
  end

  context 'when loading funds' do
    let(:funds_csv) { load_ledgers_task.send(:funds_csv) }
    let(:uuid_maps) do
      [AcquisitionsUuidsHelpers.ledgers, AcquisitionsUuidsHelpers.acq_units, AcquisitionsUuidsHelpers.finance_groups,
       AcquisitionsUuidsHelpers.fund_types]
    end
    let(:fund) { load_funds_task.send(:funds_hash, funds_csv[0], uuid_maps)['fund'] }

    it 'creates the fund hash' do
      expect(fund).to be_kind_of(Hash)
    end

    it 'creates the hash key and value for fund name' do
      expect(fund['name']).to eq 'FUND_NAME'
    end

    it 'creates the hash key and value for fund code' do
      expect(fund['code']).to eq 'FUND_NAME-SUL'
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
      expect(load_funds_task.send(:funds_hash, funds_csv[0], uuid_maps)['groupIds']).to eq ['abc-123']
    end
  end

  context 'when loading budgets' do
    let(:budgets_csv) { load_budgets_task.send(:budgets_csv) }
    let(:uuid_maps) do
      [AcquisitionsUuidsHelpers.bus_funds, AcquisitionsUuidsHelpers.law_funds, AcquisitionsUuidsHelpers.sul_funds,
       AcquisitionsUuidsHelpers.acq_units, AcquisitionsUuidsHelpers.fiscal_years,
       AcquisitionsUuidsHelpers.expense_classes]
    end

    it 'creates the hash key and value for budget name' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['name']).to eq 'FUND_NAME-SUL-FYCODE'
    end

    it 'creates the hash key and value for budgetStatus' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['budgetStatus']).to eq 'Active'
    end

    it 'creates the hash key and value for budget allocated' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['allocated']).to eq '1000'
    end

    it 'creates the hash key and value for fundId' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['fundId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for fiscalYearId' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['fiscalYearId']).to eq 'abc-123'
    end

    it 'creates the hash key and value for acqUnitIds' do
      expect(load_budgets_task.send(:budgets_hash, budgets_csv[0], uuid_maps)['acqUnitIds']).to include 'acq-123'
    end

    it 'creates the hash key and value for statusExpenseClasses' do
      expect(load_budgets_task.send(:budgets_hash,
                                    budgets_csv[0], uuid_maps)['statusExpenseClasses'])
        .to include(a_hash_including('expenseClassId' => 'exp-123'))
    end
  end
end
