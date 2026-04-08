# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'organizations rake tasks' do
  let(:load_interfaces_task) { Rake.application.invoke_task 'organizations:load_interfaces' }
  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)
      .to_return(body: '{ "okapiToken": "adshjr34h" }')

    stub_request(:post, %r{.*organizations-storage/interfaces.*})
      .to_return(status: 200)
  end

  context 'when loading interfaces' do
    let(:interfaces_json) { load_interfaces_task.send(:interfaces_json) }

    it 'supplies valid json for posting interfaces' do
      # use fixture data where type field is empty array.
      # something with the way the schema is done, a type field with an enum value, e.g. ["Invoices"], gets the error
      # "The property '#/type/0' of type string did not match the following type: object"
      expect(interfaces_json['interfaces'][3]).to match_json_schema('mod-organizations-storage', 'interface')
    end
  end
end
