# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'boundwith rake tasks' do
  let(:load_bw_parts_task) { Rake.application.invoke_task 'inventory:load_bw_parts[bw-parts.csv]' }
  let(:fixture_data) { load_bw_parts_task.send(:bw_parts_csv, 'bw-parts.csv') }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/inventory-storage/bound-with-parts')
  end

  context 'when loading boundwith parts' do
    it 'creates the hash key and value for itemId' do
      expect(fixture_data.sample['itemId']).to eq '0006666d-a927-5081-8feb-39af88ff8708'
    end

    it 'creates the hash key and value for holdingsRecordId' do
      expect(fixture_data.sample['holdingsRecordId']).to eq '8466c07b-eccf-5ddf-9916-a59dbcde3cba'
    end
  end
end
