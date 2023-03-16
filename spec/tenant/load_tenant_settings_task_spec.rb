# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'tenant settings rake tasks' do
  let(:load_institutions_task) { Rake.application.invoke_task 'tenant:load_institutions' }
  let(:load_campuses_task) { Rake.application.invoke_task 'tenant:load_campuses' }
  let(:load_libraries_task) { Rake.application.invoke_task 'tenant:load_libraries' }
  let(:load_service_points_task) { Rake.application.invoke_task 'tenant:load_service_points' }
  let(:load_locations_task) { Rake.application.invoke_task 'tenant:load_locations' }
  let(:load_addresses_task) { Rake.application.invoke_task 'tenant:load_tenant_addresses' }
  let(:load_calendars) { Rake.application.invoke_task 'tenant:load_calendars' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/location-units/institutions')
    stub_request(:get, 'http://example.com/location-units/institutions')
      .with(query: hash_including)
      .to_return(body: '{ "locinsts": [{ "id": "abc-123", "name": "Stanford University", "code": "SU" }] }')

    stub_request(:post, 'http://example.com/location-units/campuses')
    stub_request(:get, 'http://example.com/location-units/campuses')
      .with(query: hash_including)
      .to_return(body: '{ "loccamps": [{ "id": "abc-123", "name": "Stanford Libraries", "code": "SUL" }] }')

    stub_request(:post, 'http://example.com/service-points')
    stub_request(:get, 'http://example.com/service-points')
      .with(query: hash_including)
      .to_return(body: '{ "servicepoints": [{ "id": "abc-123", "name": "Green", "code": "GREEN-LOAN" }] }')

    stub_request(:get, 'http://example.com/staff-slips-storage/staff-slips')
      .with(query: hash_including)
      .to_return(body: '{ "staffSlips": [{ "id": "abc-123" }] }')

    stub_request(:post, 'http://example.com/location-units/libraries')
    stub_request(:get, 'http://example.com/location-units/libraries')
      .with(query: hash_including)
      .to_return(body: '{ "loclibs": [{ "id": "abc-123", "name": "Green Library", "code": "GREEN" }] }')

    stub_request(:post, 'http://example.com/locations')
    stub_request(:get, 'http://example.com/locations')
      .with(query: hash_including)
      .to_return(body: '{ "locations": [{ "id": "abc-123", "name": "Green Stacks", "code": "GREEN" }] }')

    stub_request(:post, 'http://example.com/calendars/calendar')
  end

  context 'when loading institutions' do
    it 'creates the hash key and value for the institution name' do
      expect(load_institutions_task.send(:institutions_csv)[0]['name']).to eq 'Tenant name'
    end

    it 'creates the hash key and value for the institution description' do
      expect(load_institutions_task.send(:institutions_csv)[0]['code']).to eq 'Tenant ID'
    end
  end

  context 'when loading campuses' do
    let(:campus_csv) { load_campuses_task.send(:campuses_csv) }
    let(:institution_uuid) { 'abc-123' }

    it 'creates the hash key and value for the campus name' do
      expect(load_campuses_task.send(:campus_hash, campus_csv[0], institution_uuid)['name']).to eq 'Campus name'
    end

    it 'creates the hash key and value for the campus code' do
      expect(load_campuses_task.send(:campus_hash, campus_csv[0], institution_uuid)['code']).to eq 'CAMPUS_CODE'
    end

    it 'creates the hash key and value for the institutionId' do
      expect(load_campuses_task.send(:campus_hash, campus_csv[0], institution_uuid)['institutionId']).to eq 'abc-123'
    end
  end

  context 'when loading libraries' do
    let(:library_csv) { load_libraries_task.send(:libraries_csv) }
    let(:campus_uuid_map) { Uuids.campuses }

    it 'creates the hash key and value for the library name' do
      expect(load_libraries_task.send(:library_hash, library_csv[0], campus_uuid_map)['name']).to eq 'Library name'
    end

    it 'creates the hash key and value for the library code' do
      expect(load_libraries_task.send(:library_hash, library_csv[0], campus_uuid_map)['code']).to eq 'LIB'
    end

    it 'creates the hash key and value for the library campusId' do
      expect(load_libraries_task.send(:library_hash, library_csv[0], campus_uuid_map)['campusId']).to eq 'abc-123'
    end
  end

  context 'when loading service points' do
    let(:service_point_csv) { load_service_points_task.send(:service_points_csv) }

    it 'creates the hash key and value for the name' do
      expect(load_service_points_task.send(:service_points_hash, service_point_csv[0])['name']).to eq 'sp-name'
    end

    it 'creates the hash key and value for the code' do
      expect(load_service_points_task.send(:service_points_hash, service_point_csv[0])['code']).to eq 'SP_CODE'
    end

    it 'creates the hash key and value for the discoveryDisplayName' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[0])['discoveryDisplayName']).to eq 'Service point desk'
    end

    it 'creates the hash key and value for the description' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[0])['description']).to eq 'service point desc'
    end

    it 'creates the hash key and value for the pickupLocation' do
      expect(load_service_points_task.send(:service_points_hash, service_point_csv[0])['pickupLocation']).to eq 'true'
    end

    it 'creates the hash key and value for the holdShelfExpiryPeriod duration' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[0])['holdShelfExpiryPeriod']['duration'])
        .to eq '7'
    end

    it 'creates the hash key and value for the holdShelfExpiryPeriod intervalId' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[0])['holdShelfExpiryPeriod']['intervalId'])
        .to eq 'Days'
    end

    it 'does not create a hash key and value for holdShelfExpiryPeriod if pickupLocation is false' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[1])).not_to have_key 'holdShelfExpiryPeriod'
    end

    it 'creates the hash keys and values for the staffSlips id' do
      staff_slips = load_service_points_task.send(:service_points_hash, service_point_csv[0])['staffSlips']
      staff_slips.each do |s|
        expect(s['id']).to eq 'abc-123'
      end
    end

    it 'creates the hash keys and values for the staffSlips printByDefault' do
      staff_slips = load_service_points_task.send(:service_points_hash, service_point_csv[0])['staffSlips']
      staff_slips.each do |s|
        expect(s['printByDefault']).to eq 'false'
      end
    end

    it 'removes the hash key and value for intervalId' do
      expect(load_service_points_task.send(:service_points_hash, service_point_csv[0])).not_to have_key 'intervalId'
    end

    it 'removes the hash key and value for printDefaultHold' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[0])).not_to have_key 'printDefaultHold'
    end

    it 'removes the hash key and value for printDefaultTransit' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[0])).not_to have_key 'printDefaultTransit'
    end

    it 'removes the hash key and value for printDefaultPickSlip' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[0])).not_to have_key 'printDefaultPickSlip'
    end

    it 'removes the hash key and value for printDefaultRequestDelivery' do
      expect(load_service_points_task.send(:service_points_hash,
                                           service_point_csv[0])).not_to have_key 'printDefaultRequestDelivery'
    end
  end

  context 'when loading locations' do
    let(:location_csv) { load_locations_task.send(:locations_csv) }
    let(:uuid_maps) { load_locations_task.send(:uuid_maps) }
    let(:location_hash) { load_locations_task.send(:locations_hash, location_csv[0], Uuids.uuid_maps) }

    it 'creates the hash keys and values for the code' do
      expect(location_hash['code']).to eq 'CODE'
    end

    it 'creates the hash keys and values for the name' do
      expect(location_hash['name']).to eq 'Location name'
    end

    it 'creates the hash keys and values for isActive' do
      expect(location_hash['isActive']).to eq 'true'
    end

    it 'creates the hash keys and values for the description' do
      expect(location_hash['description']).to eq 'location desc'
    end

    it 'creates the hash keys and values for discoveryDisplayName' do
      expect(location_hash['discoveryDisplayName']).to eq 'Display name'
    end

    it 'creates the hash keys and values for the institutionId' do
      expect(location_hash['institutionId']).to eq 'abc-123'
    end

    it 'creates the hash keys and values for the libraryId' do
      expect(location_hash['libraryId']).to eq 'abc-123'
    end

    it 'creates the hash keys and values for the campusId' do
      expect(location_hash['campusId']).to eq 'abc-123'
    end

    it 'creates the hash keys and values for the primaryServicePoint' do
      expect(location_hash['primaryServicePoint']).to eq 'abc-123'
    end

    it 'creates the hash keys and values for servicePointIds' do
      expect(location_hash['servicePointIds']).to eq ['abc-123']
    end

    it 'removes the hash key for institutionCode' do
      expect(location_hash).not_to have_key 'institutionCode'
    end

    it 'removes the hash key for campusCode' do
      expect(location_hash).not_to have_key 'campusCode'
    end

    it 'removes the hash key for libraryCode' do
      expect(location_hash).not_to have_key 'libraryCode'
    end

    it 'removes the hash key for primaryServicePointCode' do
      expect(location_hash).not_to have_key 'primaryServicePointCode'
    end
  end

  context 'when creating calendars' do
    let(:calendars_json) { load_course_status.send(:calendars_json) }

    # new json schemas not available for mod-calendar
    xit 'supplies valid json for posting calendars' do
      expect(calendars_json['calendars'].sample).to match_json_schema('mod-calendar', 'calendars')
    end
  end
end
