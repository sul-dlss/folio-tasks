# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'alternative title type tasks' do
  let(:load_alt_title_types_task) { Rake.application.invoke_task 'inventory:load_alt_title_types' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/alternative-title-types')
  end

  context 'when loading item note types' do
    let(:alt_title_types_csv) { load_alt_title_types_task.send(:alt_title_types_csv) }

    it 'creates the hash key and value for the alternative title name' do
      expect(load_alt_title_types_task.send(:alt_title_types_csv)[0]['name']).to eq 'Added title page title'
    end

    it 'creates the hash key and value for the alternative title source' do
      expect(load_alt_title_types_task.send(:alt_title_types_csv)[0]['source']).to eq 'folio'
    end
  end
end
