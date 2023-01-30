# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'sip2 settings rake tasks' do
  let(:load_sip2_configs) { Rake.application.invoke_task 'configurations:load_sip2_configs' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/configurations/entries')
    stub_request(:get, 'http://example.com/service-points')
      .with(query: hash_including)
      .to_return(body: '{ "servicepoints": [{ "id": "b0aed71d", "code": "ART" }] }')
  end

  context 'when loading sip2 configurations' do
    let(:json) do
      {
        "module": "edge-sip2",
        "configName": "selfCheckoutConfig.b0aed71d",
        "enabled": true,
        "value": "{\"timeoutPeriod\": 5,\"retriesAllowed\": 3,\"checkinOk\": true,\"checkoutOk\": true,\"acsRenewalPolicy\": false,\"libraryName\": \"Stanford University Libraries\",\"terminalLocation\": \"b0aed71d\"}"
      }
    end

    before { load_sip2_configs }

    it 'does' do
      expect(WebMock).to have_requested(:post, 'http://example.com/configurations/entries')
        .with(body: json).at_least_once
    end
  end
end
