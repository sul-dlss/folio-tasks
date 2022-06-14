# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'item loan type tasks' do
  let(:load_item_loan_types_task) { Rake.application.invoke_task 'inventory:load_item_loan_types' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/loan-types')
  end

  context 'when loading item note types' do
    let(:item_loan_types_csv) { load_item_loan_types_task.send(:item_loan_types_csv) }

    it 'creates the hash key and value for the loan type name' do
      expect(load_item_loan_types_task.send(:item_loan_types_csv)[0]['name']).to eq 'Standard book loan'
    end
  end
end
