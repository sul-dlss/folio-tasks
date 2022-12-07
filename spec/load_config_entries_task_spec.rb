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
    let(:config_json) { load_configurations_task.send(:config_entry_json, 'SMTP_SERVER.json') }
    let(:updated_config_entry_json) do
      load_configurations_task.send(:updated_config_entry_json, config_json.values[0][0])
    end

    it 'creates a json object' do
      expect(config_json.values.sample[0]).to match_json_schema('mod-configuration', 'kv_configuration')
    end

    it 'overwrites host with correct namespace value' do
      expect(updated_config_entry_json['value']).to eq 'mail.test.svc.cluster.local'
    end
  end
end
