# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'acquisitions units rake tasks' do
  let(:load_acq_units_task) { Rake.application.invoke_task 'acquisitions:load_acq_units' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/acquisitions-units-storage/units')
    stub_request(:get, 'http://example.com/acquisitions-units-storage/units')
      .with(query: hash_including)
      .to_return(body: '{ "acquisitionsUnits": [{ "id": "acq-123" }] }')
  end

  context 'when loading acquisitions units' do
    it 'creates the hash key and value for acquisitions unit name' do
      expect(load_acq_units_task.send(:acq_units_csv)[0]['name']).to eq 'SUL'
    end

    it 'creates downcase boolean value for acq unit isDeleted field' do
      expect(load_acq_units_task.send(:acq_units_csv)[0]['isDeleted']).to eq 'false'
    end
  end
end
