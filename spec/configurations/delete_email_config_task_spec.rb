# frozen_string_literal: true

require 'rake'
require 'spec_helper'

RSpec.configure do |config|
  config.before(:suite) do
    Dir.glob('tasks/helpers/configurations.rb').each { |r| Rake::DefaultLoader.new.load r }
  end
end

describe 'delete email config rake task' do
  let(:delete_email_config_task) { Rake.application.invoke_task 'configurations:delete_email_config' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/smtp-configuration')
      .with(query: hash_including)
      .to_return(body: '{ "smtpConfigurations": [{"id": "abc-123"}] }')

    stub_request(:delete, 'http://example.com/smtp-configuration/abc-123')

    delete_email_config_task
  end

  it 'deletes the email config' do
    expect(WebMock).to have_requested(:delete, 'http://example.com/smtp-configuration/abc-123').at_least_once
  end
end
