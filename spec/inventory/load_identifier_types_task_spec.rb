# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'identifier types rake tasks' do
  let(:load_identifier_types_task) { Rake.application.invoke_task 'inventory:load_identifier_types' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/identifier-types')
  end

  context 'when loading identifier types' do
    let(:identifier_types_csv) { load_identifier_types_task.send(:identifier_types_csv) }

    it 'creates the hash key and value for a identifier type name' do
      expect(load_identifier_types_task.send(:identifier_types_csv)[0]['name']).to eq 'ReShare Request ID'
    end

    it 'creates the hash key and value for a identifier type id' do
      expect(load_identifier_types_task.send(:identifier_types_csv)[0]['id']).to eq 'b514359d-8108-4760-9e5e-6ae2e8fee7f8'
    end

    it 'creates the hash key and value for a identifier type source' do
      expect(load_identifier_types_task.send(:identifier_types_csv)[0]['source']).to eq 'local'
    end
  end
end
