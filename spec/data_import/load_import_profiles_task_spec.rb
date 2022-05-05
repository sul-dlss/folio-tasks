# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'data import profile rake tasks' do
  let(:load_job_profiles_task) { Rake.application.invoke_task 'load_job_profiles' }
  let(:load_action_profiles_task) { Rake.application.invoke_task 'load_action_profiles' }
  let(:load_mapping_profiles_task) { Rake.application.invoke_task 'load_mapping_profiles' }
  let(:profile_associations_task) { Rake.application.invoke_task 'create_profile_associations' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/data-import-profiles/jobProfiles')
    stub_request(:post, 'http://example.com/data-import-profiles/actionProfiles')
    stub_request(:post, 'http://example.com/data-import-profiles/mappingProfiles')

    stub_request(:post, 'http://example.com/data-import-profiles/profileAssociations')
      .with(query: hash_including)

    stub_request(:get, 'http://example.com/data-import-profiles/actionProfiles')
      .with(query: hash_including)
      .to_return(body: '{ "actionProfiles": [{ "id": "0283111b-203b-4da9-869f-cbe55f725346" }] }')

    stub_request(:get, 'http://example.com/data-import-profiles/jobProfiles')
      .with(query: hash_including)
      .to_return(body: '{ "jobProfiles": [{ "id": "7f7abc55-2424-4a55-9a80-747f3b7cbab4" }] }')

    stub_request(:get, 'http://example.com/data-import-profiles/mappingProfiles')
      .with(query: hash_including)
      .to_return(body: '{ "mappingProfiles": [{ "id": "8cd22a28-4293-439d-a4c4-193f4a078e65" }] }')
  end

  context 'when loading job profiles' do
    let(:job_profiles_json) { load_job_profiles_task.send(:job_profiles_json) }

    it 'creates a json object' do
      expect(job_profiles_json.values.sample[0]).to match_json_schema('mod-data-import-converter-storage',
                                                                      'jobProfile')
    end
  end

  context 'when loading action profiles' do
    let(:action_profiles_json) { load_action_profiles_task.send(:action_profiles_json) }

    it 'creates a json object' do
      expect(action_profiles_json.values.sample[0]).to match_json_schema('mod-data-import-converter-storage',
                                                                         'actionProfile')
    end
  end

  context 'when loading mapping profiles' do
    let(:mapping_profiles_json) { load_mapping_profiles_task.send(:mapping_profiles_json) }

    it 'creates a json object' do
      WebMock.allow_net_connect!
      expect(mapping_profiles_json.values.sample[0]).to match_json_schema('mod-data-import-converter-storage',
                                                                          'mappingProfile')
    end
  end

  context 'when loading profile associations' do
    let(:action_profiles_json) { profile_associations_task.send(:action_profiles_json) }
    let(:profile_associations_ids) do
      profile_associations_task.send(:profile_associations_ids, action_profiles_json.values.sample[0])
    end

    it 'creates array of uuids' do
      expect(profile_associations_ids).to be_kind_of(Array)
    end

    it 'creates valid profile associations json for child profile' do
      expect(profile_associations_task.send(:profile_associations_payload,
                                            profile_associations_ids[0], 'ACTION_PROFILE',
                                            profile_associations_ids[2], 'MAPPING_PROFILE')).to match_json_schema(
                                              'mod-data-import-converter-storage', 'profileAssociation'
                                            )
    end

    it 'creates valid profile associations json for parent profile' do
      expect(profile_associations_task.send(:profile_associations_payload,
                                            profile_associations_ids[1], 'JOB_PROFILE',
                                            profile_associations_ids[0], 'ACTION_PROFILE')).to match_json_schema(
                                              'mod-data-import-converter-storage', 'profileAssociation'
                                            )
    end
  end
end
