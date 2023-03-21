# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load email config rake task' do
  let(:load_email_config_task) do
    Rake.application.invoke_task 'configurations:load_email_config'
  end

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/smtp-configuration')
  end

  context 'when loading email configuration' do
    let(:email_config_json) { load_email_config_task.send(:email_configuration)['smtpConfigurations'][0] }

    it 'creates a json object' do
      expect(email_config_json.to_json).to match_json_schema('mod-email', 'smtp-configuration')
    end

    it 'overwrites host with correct namespace value' do
      expect(email_config_json['host'].to_s).to eq 'mail.folio-test.svc.cluster.local'
    end
  end
end
