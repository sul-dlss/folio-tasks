# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'delete module config rake task' do
  let(:delete_module_configs_task) { Rake.application.invoke_task 'configurations:delete_module_configs[LOGIN-SAML]' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/configurations/entries?limit=50')
      .with(query: { query: 'module==LOGIN-SAML' })
      .to_return(body: '{ "configs": [{"id": "saml-123"}, {"id": "saml-456"}] }')

    stub_request(:delete, %r{.*configurations/entries/saml.*})

    delete_module_configs_task
  end

  it 'deletes configs for a specified module' do
    expect(WebMock).to have_requested(:delete, 'http://example.com/configurations/entries/saml-456').once
  end
end
