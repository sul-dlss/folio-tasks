# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'statistical codes rake tasks' do
  let(:load_statistical_code_types) { Rake.application.invoke_task 'inventory:load_statistical_code_types' }
  let(:load_statistical_codes) { Rake.application.invoke_task 'inventory:load_statistical_codes' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/statistical-codes')
    stub_request(:post, 'http://example.com/statistical-code-types')
  end

  context 'when creating statistical code types' do
    let(:statistical_code_types_json) { load_statistical_code_types.send(:statistical_code_types_json) }

    it 'supplies valid json for loading statistical code types' do
      expect(statistical_code_types_json['statisticalCodeTypes'].sample).to match_json_schema('mod-inventory-storage', 'statisticalcodetype')
    end
  end

  context 'when creating statistical codes' do
    let(:statistical_codes_json) { load_statistical_code_types.send(:statistical_codes_json) }

    it 'supplies valid json for loading statistical codes' do
      expect(statistical_codes_json['statisticalCodes'].sample).to match_json_schema('mod-inventory-storage', 'statisticalcode')
    end
  end
end
