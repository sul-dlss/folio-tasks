# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load config entries rake tasks' do
  let(:load_configurations_task) do
    Rake.application.invoke_task 'configurations:load_module_configs[SMTP_SERVER]'
  end

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/configurations/entries')
  end

  context 'when loading configurations' do
    let(:config_json) { load_configurations_task.send(:load_module_configs, 'SMTP_SERVER') }

    it 'creates a json object' do
      expect(config_json.sample).to match_json_schema('mod-configuration', 'kv_configuration')
    end

    it 'overwrites host with correct namespace value' do
      expect(config_json[0]['value'].to_s).to eq 'mail.test.svc.cluster.local'
    end
  end
end
