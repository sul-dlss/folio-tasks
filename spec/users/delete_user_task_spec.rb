# frozen_string_literal: true

require 'rake'
require 'spec_helper'

RSpec.configure do |config|
  config.before(:suite) do
    Dir.glob('tasks/helpers/users.rb').each { |r| Rake::DefaultLoader.new.load r }
  end
end

describe 'deleting users/perms/service-points' do
  let(:delete_user_task) { Rake.application.invoke_task 'users:delete_user["someuser"]' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/users')
      .with(query: hash_including)
      .to_return(body: '{ "users": [{"id": "abc-123"}] }')

    stub_request(:get, 'http://example.com/perms/users')
      .with(query: hash_including)
      .to_return(body: '{ "permissionUsers": [{"id": "def-456"}] }')

    stub_request(:get, 'http://example.com/service-points-users')
      .with(query: hash_including)
      .to_return(body: '{"servicePointsUsers": [{"id": "ghi-789"}] }')

    stub_request(:delete, 'http://example.com/users/abc-123')
    stub_request(:delete, 'http://example.com/perms/users/def-456')
    stub_request(:delete, 'http://example.com/service-points-users/ghi-789')

    delete_user_task
  end

  it 'deletes the user record' do
    expect(WebMock).to have_requested(:delete, 'http://example.com/users/abc-123').at_least_once
  end
end
