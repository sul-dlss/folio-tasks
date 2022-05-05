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

  desc 'create data import profile associations in folio'
  task :create_profile_associations do
    action_profiles_json.each_value do |v|
      v.each do |obj|
        uuid, parent_uuid, child_uuid = profile_associations_ids(obj)
        child_association = profile_associations_payload(uuid, 'ACTION_PROFILE', child_uuid, 'MAPPING_PROFILE')
        profile_associations_post(child_association, 'ACTION_PROFILE', 'MAPPING_PROFILE')
        parent_association = profile_associations_payload(parent_uuid, 'JOB_PROFILE', uuid, 'ACTION_PROFILE')
        profile_associations_post(parent_association, 'JOB_PROFILE', 'ACTION_PROFILE')
      end
    end
  end
end
