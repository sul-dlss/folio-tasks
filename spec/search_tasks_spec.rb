# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'search rake tasks' do
  let(:recreate_resource_index_task) { Rake.application.invoke_task 'search:recreate_resource_index[authority]' }
  let(:reindex_resource_index_task) { Rake.application.invoke_task 'search:reindex_resource_index[authority]' }
  let(:recreate_instances_index_task) { Rake.application.invoke_task 'search:recreate_instances_index' }
  let(:upload_index_task) { Rake.application.invoke_task 'search:upload_index[instance]' }
  let(:reindex_status_task) { Rake.application.invoke_task 'search:reindex_status' }
  let(:reindex_failed_merge_task) { Rake.application.invoke_task 'search:reindex_failed_merge' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)
      .to_return(body: '{ "okapiToken": "adshjr34h" }')

    stub_request(:post, 'http://example.com/search/index/inventory/reindex')

    stub_request(:post, %r{.*search/index/instance-records/reindex.*})
      # .to_return({status: 201})
    
    stub_request(:get, 'http://example.com/search/index/instance-records/reindex/status')
  end

  context 'when re-creating resource index' do
    let(:obj) { {recreateIndex: true, resourceName: "authority"} }
    let(:path) { "http://example.com" + recreate_resource_index_task.send(:resource_path) }

    it 'posts correct json object with recreateIndex true' do
      expect(WebMock).to have_requested(:post, path)
        .with(body: obj).at_least_once
    end
  end

  context 'when reindexing resource index' do
    let(:obj) { {recreateIndex: false, resourceName: "authority"} }
    let(:path) { "http://example.com" + reindex_resource_index_task.send(:resource_path) }

    it 'posts correct json object with recreateIndex false' do
      expect(WebMock).to have_requested(:post, path)
        .with(body: obj).at_least_once
    end
  end

  context 'when recreating instance index' do
    let(:path) { "http://example.com" + recreate_instances_index_task.send(:instance_path) }

    it 'uses to correct endpoint' do
      expect(path).to match(/full$/)
    end

    it 'posts to endpoint' do
      request = recreate_instances_index_task.send(:reindex, path)
      expect(request).to have_requested(:post, path).at_least_once
    end
  end

  context 'when uploading an entity index' do
    let(:obj) { {entityTypes: ['instance']} }
    let(:path) { "http://example.com" + upload_index_task.send(:upload_index_path) }

    it 'uses to correct endpoint' do
      expect(path).to match(/upload$/)
    end

    it 'posts correct json object with entityTypes instance' do
      request = upload_index_task.send(:reindex, path, obj)
      expect(request).to have_requested(:post, path)
        .with(body: obj).at_least_once
    end
  end

  context 'when uploading all entity type indexes' do
    let(:obj) { {entityTypes: ['instance', 'subject', 'contributor', 'classification', 'call-number']} }
    let(:path) { "http://example.com" + upload_index_task.send(:upload_index_path) }

    it 'uses to correct endpoint' do
      expect(path).to match(/upload$/)
    end

    it 'posts correct json object with all entityTypes' do
      request = upload_index_task.send(:reindex, path, obj)
      expect(request).to have_requested(:post, path)
        .with(body: obj).at_least_once
    end
  end

  context 'when monitoring the reindex status' do
    it 'makes the request to correct endpoint' do
      request = reindex_status_task.send(:reindex_status)
      expect(request).to have_requested(:get, 'http://example.com/search/index/instance-records/reindex/status').at_least_once
    end
  end

  context 'when reindexing failed merge ranges' do
    let(:path) { "http://example.com" + reindex_failed_merge_task.send(:failed_merge_path) }

    it 'uses to correct endpoint' do
      expect(path).to match(/merge\/failed$/)
    end

    it 'makes the request' do
      request = reindex_failed_merge_task.send(:reindex, path)
      expect(request).to have_requested(:post, path).at_least_once
    end
  end
end
