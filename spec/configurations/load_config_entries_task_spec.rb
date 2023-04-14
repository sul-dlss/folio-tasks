# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load config entries rake tasks' do
  let(:load_configurations_task) do
    Rake.application.invoke_task 'configurations:load_module_configs[CHECKOUT]'
  end
  let(:load_login_configs_task) { Rake.application.invoke_task 'configurations:load_login_configs' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/configurations/entries')
  end

  context 'when loading configurations' do
    let(:config_json) { load_configurations_task.send(:load_module_configs, 'CHECKOUT') }

    it 'creates a json object' do
      expect(config_json.sample).to match_json_schema('mod-configuration', 'kv_configuration')
    end
  end

  context 'when loading login configurations' do
    it 'creates the hash key and value for the config name' do
      expect(load_login_configs_task.send(:login_configs_tsv)[0]['configName']).to eq 'login.fail.attempts'
    end

    it 'creates the hash key and value for the module name' do
      expect(load_login_configs_task.send(:login_configs_tsv)[0]['module']).to eq 'LOGIN'
    end

    it 'creates the hash key and value for value' do
      expect(load_login_configs_task.send(:login_configs_tsv)[0]['value']).to eq 10
    end
  end
end
