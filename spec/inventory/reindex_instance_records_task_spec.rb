# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'Reindexing search records from cql query' do
  let(:query) { 'hrid==Q*' }
  let(:instance_response) { '{ "instances": [ "id": "abc-123", "hrid": "a123", "title": "The Title" ], "totalRecords": 100}' }

  let(:reindex_search_records_task) { Rake.application.invoke_task "inventory:reindex_search_records[#{query}]" }

  # context 'when getting the the total number of records for a query' do
  # end
  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/instance-storage/instances')
    .with(query: "limit=0&query=#{query}")
    .to_return(body: '{ "instances": [ ], "totalRecords": 100}')

    stub_request(:get, 'http://example.com/instance-storage/instances')
    .with(query: "limit=100&offset=0&query=#{query}")
    .to_return(body: instance_response)

    reindex_search_records_task
  end

  it 'Gets the total number of records' do
    expect(WebMock).to have_requested(:get, 'http://example.com/instance-storage/instances').at_least_once
  end

end