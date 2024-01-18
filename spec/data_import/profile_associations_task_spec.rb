# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'pulling and loading profile associations' do
  let(:load_profile_associations_task) do
    Rake.application.invoke_task 'data_import:load_profile_associations'
  end

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    associations_webmock

    body = {
      profileAssociations: [
        {
          id: 'd0ebbdbe-2f0f-11eb-adc1-0242ac120002',
          masterProfileId: 'd0ebb7b0-2f0f-11eb-adc1-0242ac120002',
          detailProfileId: 'd0ebba8a-2f0f-11eb-adc1-0242ac120002',
          masterProfileType: 'JOB_PROFILE',
          detailProfileType: 'ACTION_PROFILE'
        }
      ]
    }

    stub_request(:get, 'http://example.com/data-import-profiles/profileAssociations')
      .with(query: { 'master' => 'JOB_PROFILE', 'detail' => 'ACTION_PROFILE' })
      .to_return(body: body.to_json)

    stub_request(:put, 'http://example.com/data-import-profiles/profileAssociations/d0ebbdbe-2f0f-11eb-adc1-0242ac120002')
      .with(query: 'detail=ACTION_PROFILE&master=JOB_PROFILE')

    load_profile_associations_task.send(:profile_associations_json)
  end

  # Skip because Webmock does not recognize successive mocks for the same uri (even with different query strings)
  it 'does a post for an new association id', skip: 'Webmock issue with successive mocks' do
    expect(WebMock).to have_requested(:post, 'http://example.com/data-import-profiles/profileAssociations?detail=MATCH_PROFILE&master=JOB_PROFILE').at_least_once
  end

  it 'does a put for an existing association id', skip: 'Webmock issue with successive mocks' do
    expect(WebMock).to have_requested(:put, 'http://example.com/data-import-profiles/profileAssociations/d0ebbdbe-2f0f-11eb-adc1-0242ac120002?detail=ACTION_PROFILE&master=JOB_PROFILE').at_least_once
  end

  it 'creates a json object' do
    expect(profile_associations_json.values.sample[0]).to match_json_schema('mod-data-import-converter-storage',
                                                                            'profileAssociation')
  end
end

def associations_webmock
  master = %w[JOB ACTION MATCH]
  master.each do |profile_m|
    uuid_m = FolioUuid.new.generate(Settings.okapi.url, 'other', profile_m)

    details = profile_m == 'ACTION' ? %w[ACTION MAPPING MATCH] : %w[ACTION MATCH]
    details.each do |profile_d|
      uuid_d = FolioUuid.new.generate(Settings.okapi.url, 'other', profile_d)
      body = {
        profileAssociations: [
          {
            id: FolioUuid.new.generate(Settings.okapi.url, 'other', rand.to_s[2..5]),
            masterProfileId: uuid_m,
            detailProfileId: uuid_d,
            masterProfileType: "#{profile_m}_PROFILE",
            detailProfileType: "#{profile_d}_PROFILE"
          }
        ]
      }

      stub_request(:get, 'http://example.com/data-import-profiles/profileAssociations')
        .with(query: { 'master' => "#{profile_m}_PROFILE", 'detail' => "#{profile_d}_PROFILE" })
        .to_return(body: body.to_json)

      stub_request(:post, 'http://example.com/data-import-profiles/profileAssociations')
        .with(query: { 'master' => "#{profile_m}_PROFILE", 'detail' => "#{profile_d}_PROFILE" })
    end
  end
end
