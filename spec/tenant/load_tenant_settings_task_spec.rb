# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'tenant settings rake tasks' do
  let(:load_locations_task) { Rake.application.invoke_task 'tenant:load_locations' }
  let(:load_calendars) { Rake.application.invoke_task 'tenant:load_calendars' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)
      .to_return(body: '{ "okapiToken": "adshjr34h" }')

    stub_request(:post, 'http://example.com/locations')
    stub_request(:get, 'http://example.com/locations')
      .with(query: hash_including)
      .to_return(body: '{ "locations": [{ "id": "abc-123", "name": "Green Stacks", "code": "GREEN" }] }')

    stub_request(:post, 'http://example.com/calendar/calendars')
  end

  context 'when loading locations from folio env (STAGE=orig)' do
    let(:locations_json) { load_locations_task.send(:locations_json) }

    it 'supplies valid json for loading locations' do
      expect(locations_json['locations'].sample).to match_json_schema('mod-inventory-storage', 'location')
    end
  end

  context 'when creating calendars' do
    let(:calendars_json) { load_calendars.send(:calendars_json) }

    it 'supplies valid json for posting calendars', skip: 'new json schemas not available for mod-calendar' do
      expect(calendars_json['calendars'].sample).to match_json_schema('mod-calendar', 'calendars')
    end

    it 'posts calendar json data' do
      expect(load_calendars).to have_requested(:post, 'http://example.com/calendar/calendars')
        .with(body: '{"id":"22b40887-20a4-4927-a2da-5886a6c6ea43","name":"Law Book Cabinet - Course Reserves","startDate":"1992-01-01","endDate":"2040-12-31","assignments":["0939d005-3e55-46d4-ab36-6f9099675876"],"normalHours":[{"startDay":"SUNDAY","startTime":"00:00:00","endDay":"SATURDAY","endTime":"23:59:00"}],"exceptions":[]}')
    end
  end
end
