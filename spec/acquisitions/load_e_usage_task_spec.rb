# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load e-usage rake tasks' do
  let(:load_data_providers_task) { Rake.application.invoke_task 'acquisitions:load_e_usage_data_providers' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/usage-data-providers')
  end

  context 'when loading data providers' do
    let(:data_provider_hash) { load_data_providers_task.send(:data_providers_hash, data_providers_tsv[0]) }

    it 'creates the hash key and value for label' do
      expect(data_provider_hash['label']).to eq 'Provider Name'
    end

    it 'has a hash with key harvestingConfig' do
      expect(data_provider_hash['harvestingConfig']).to be_a(Hash)
    end

    it 'has harvestingStatus as active' do
      expect(data_provider_hash['harvestingConfig']['harvestingStatus']).to eq 'active'
    end

    it 'has harvestVia as sushi' do
      expect(data_provider_hash['harvestingConfig']['harvestVia']).to eq 'sushi'
    end

    it 'has reportRelease as an integer' do
      expect(data_provider_hash['harvestingConfig']['reportRelease']).to be_a(Integer)
    end

    it 'has an array for requestedReports' do
      expect(data_provider_hash['harvestingConfig']['requestedReports']).to be_a(Array)
    end

    it 'has sushi configs' do
      expect(data_provider_hash['harvestingConfig']['sushiConfig']).to be_a(Hash)
    end

    it 'has a serviceType' do
      expect(data_provider_hash['harvestingConfig']['sushiConfig']['serviceType']).to eq 'cs50'
    end

    it 'has a serviceUrl' do
      expect(data_provider_hash['harvestingConfig']['sushiConfig']['serviceUrl']).to eq 'https://example.com/reports/'
    end

    it 'has a hash with key sushiCredentials' do
      expect(data_provider_hash['sushiCredentials']).to be_a(Hash)
    end

    it 'has a customerId' do
      expect(data_provider_hash['sushiCredentials']['customerId']).to eq 'customer1234'
    end

    it 'has a requestorId' do
      expect(data_provider_hash['sushiCredentials']['requestorId']).to eq 'somebody@example.com'
    end

    it 'has an apiKey that can be nil' do
      expect(data_provider_hash['sushiCredentials']['apiKey']).to be_nil
    end
  end
end
