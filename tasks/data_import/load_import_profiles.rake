# frozen_string_literal: true

require_relative '../helpers/data_import'

namespace :data_import do
  include DataImportTaskHelpers

  desc 'load job profiles into folio'
  task :load_job_profiles do
    job_profiles_json.each_value do |v|
      v.each do |obj|
        payload = import_profile_hash(obj)
        job_profiles_post(payload)
      end
    end
  end

  desc 'load action profiles into folio'
  task :load_action_profiles do
    action_profiles_json.each_value do |v|
      v.each do |obj|
        payload = import_profile_hash(obj)
        action_profiles_post(payload)
      end
    end
  end

  desc 'load mapping profiles into folio'
  task :load_mapping_profiles do
    mapping_profiles_json.each_value do |v|
      v.each do |obj|
        payload = import_profile_hash(obj)
        mapping_profiles_post(payload)
      end
    end
  end

  desc 'load match profiles into folio'
  task :load_match_profiles do
    match_profiles_json.each_value do |v|
      v.each do |obj|
        payload = import_profile_hash(obj)
        match_profiles_post(payload)
      end
    end
  end

  desc 'create data import action profile associations in folio'
  task :create_action_profile_associations do
    action_profiles_json.each_value do |v|
      v.each do |obj|
        uuid, parent_job_uuid, parent_match_uuid, child_uuid = profile_associations_ids(obj)

        child_payload = profile_associations_payload(uuid, 'ACTION_PROFILE', child_uuid, 'MAPPING_PROFILE')
        profile_associations_post(child_payload, 'ACTION_PROFILE', 'MAPPING_PROFILE')

        parent_job_payload = profile_associations_payload(parent_job_uuid, 'JOB_PROFILE', uuid, 'ACTION_PROFILE')
        profile_associations_post(parent_job_payload, 'JOB_PROFILE', 'ACTION_PROFILE')

        parent_match_payload = profile_associations_payload(parent_match_uuid, 'MATCH_PROFILE', uuid, 'ACTION_PROFILE')
        profile_associations_post(parent_match_payload, 'MATCH_PROFILE', 'ACTION_PROFILE')
      end
    end
  end

  desc 'create data import match profile associations in folio'
  task :create_match_profile_associations do
    match_profiles_json.each_value do |v|
      v.each do |obj|
        uuid, parent_job_uuid, parent_match_uuid, child_uuid = profile_associations_ids(obj)

        child_payload = profile_associations_payload(uuid, 'MATCH_PROFILE', child_uuid, 'ACTION_PROFILE')
        profile_associations_post(child_payload, 'ACTION_PROFILE', 'MAPPING_PROFILE')

        parent_job_payload = profile_associations_payload(parent_job_uuid, 'JOB_PROFILE', uuid, 'MATCH_PROFILE')
        profile_associations_post(parent_job_payload, 'JOB_PROFILE', 'MATCH_PROFILE')

        parent_match_payload = profile_associations_payload(parent_match_uuid, 'MATCH_PROFILE', uuid, 'MATCH_PROFILE')
        profile_associations_post(parent_match_payload, 'MATCH_PROFILE', 'MATCH_PROFILE')
      end
    end
  end
end
