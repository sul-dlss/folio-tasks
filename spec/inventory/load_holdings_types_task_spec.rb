# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'holdings type tasks' do
  let(:load_holdings_types_task) { Rake.application.invoke_task 'inventory:load_holdings_types' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/holdings-types')
  end

  context 'when loading holdings types' do
    let(:holdings_types_csv) { load_holdings_types_task.send(:holdings_types_csv) }

    it 'creates the hash key and value for the holdings type name' do
      expect(load_holdings_types_task.send(:holdings_types_csv)[0]['name']).to eq 'Bound-with'
    end

    it 'creates the hash key and value for the holdings type source' do
      expect(load_holdings_types_task.send(:holdings_types_csv)[0]['source']).to eq 'migration'
    end

    it 'creates the hash key and value for the holdings type id' do
      expect(load_holdings_types_task.send(:holdings_types_csv)[0]['id']).to eq '5b08b35d-aaa3-4806-998c-9cd85e5bc406'
    end
  end
end
