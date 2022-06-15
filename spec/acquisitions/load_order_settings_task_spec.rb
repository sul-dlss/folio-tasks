# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load order settings rake tasks' do
  let(:load_acq_methods_task) { Rake.application.invoke_task 'acquisitions:load_acq_methods' }
  let(:load_po_lines_limit_task) { Rake.application.invoke_task 'acquisitions:load_po_lines_limit' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/orders/acquisition-methods')

    stub_request(:post, 'http://example.com/configurations/entries')
  end

  context 'when loading acquisition methods' do
    it 'creates the hash key and value for acq method value' do
      expect(load_acq_methods_task.send(:acq_methods_tsv)[0]['value']).to eq 'New Acq Method'
    end

    it 'creates the hash key and value for acq method source' do
      expect(load_acq_methods_task.send(:acq_methods_tsv)[0]['source']).to eq 'User'
    end
  end

  context 'when loading po lines limit configuration' do
    it 'has required field module' do
      expect(load_po_lines_limit_task.send(:po_lines_limit)['module']).to eq 'ORDERS'
    end

    it 'has required field configName' do
      expect(load_po_lines_limit_task.send(:po_lines_limit)['configName']).to eq 'poLines-limit'
    end

    it 'creates a string for po line limit value' do
      expect(load_po_lines_limit_task.send(:po_lines_limit)['value']).to be_a(String)
    end
  end
end
