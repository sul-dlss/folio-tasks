# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'okapi tasks' do
  let(:disable_circulation_timers_task) { Rake.application.invoke_task 'okapi:disable_circulation_timers' }
  let(:enable_circulation_timers_task) { Rake.application.invoke_task 'okapi:enable_circulation_timers' }
  let(:circ_timers) { disable_circulation_timers_task.send(:circulation_timers) }
  let(:disable_timers_task) { Rake.application.invoke_task 'okapi:disable_timers' }
  let(:all_timers) { disable_timers_task.send(:all_timers) }

  before do
    stub_request(:get, 'http://example.com/_/proxy/tenants/sul/timers')
      .with(query: hash_including)
      .to_return(body: '[ {"id": "mod-circulation_0"}, {"id": "mod-circulation-storage_0"}, {"id": "mod-circulation_1"} ]')

    stub_request(:patch, 'http://example.com/_/proxy/tenants/sul/timers')
      .to_return({ status: 204 })
  end

  context 'when disabling a circulation timer' do
    let(:disable_obj) { disable_circulation_timers_task.send(:disable_timer, circ_timers[0]) }
    let(:disable_patch) { disable_circulation_timers_task.send(:timers_patch, disable_obj.to_json) }

    it 'sends the right json data to disable timer' do
      expect(disable_obj['routingEntry']['delay']).to eq '0'
    end

    it 'sends request to disable a timer' do
      expect(disable_patch).to have_requested(:patch, 'http://example.com/_/proxy/tenants/sul/timers').at_least_once
    end
  end

  context 'when enabling a circulation timer' do
    let(:enable_obj) { enable_circulation_timers_task.send(:enable_timer, circ_timers[0]) }
    let(:enable_patch) { enable_circulation_timers_task.send(:timers_patch, enable_obj.to_json) }

    it 'sends the right json data to enable timer' do
      expect(enable_obj['routingEntry']).not_to have_key 'delay'
    end

    it 'sends request to enable a timer' do
      expect(enable_patch).to have_requested(:patch, 'http://example.com/_/proxy/tenants/sul/timers').at_least_once
    end
  end

  context 'when disabling all timers' do
    let(:disable_obj) { disable_timers_task.send(:disable_timer, all_timers[1]) }
    let(:disable_patch) { disable_timers_task.send(:timers_patch, disable_obj.to_json) }

    it 'has a list of all timers' do
      expect(all_timers.count).to eq 3
    end

    it 'sends the right json data to disable timer' do
      expect(disable_obj['routingEntry']['delay']).to eq '0'
    end

    it 'sends request to disable a timer' do
      expect(disable_patch).to have_requested(:patch, 'http://example.com/_/proxy/tenants/sul/timers').at_least_once
    end
  end
end
