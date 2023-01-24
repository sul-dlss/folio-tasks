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

  desc 'update job profiles in folio'
  task :update_job_profiles do
    job_profiles_json.each_value do |v|
      v.each do |obj|
        payload = import_profile_hash(obj)
        job_profiles_put(payload)
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

  desc 'update action profil in folio'
  task :update_action_profiles do
    action_profiles_json.each_value do |v|
      v.each do |obj|
        payload = import_profile_hash(obj)
        action_profiles_put(payload)
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

  desc 'update mapping profiles in folio'
  task :update_mapping_profiles do
    mapping_profiles_json.each_value do |v|
      v.each do |obj|
        payload = import_profile_hash(obj)
        mapping_profiles_put(payload)
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

  desc 'load profile associations into folio'
  task :load_profile_associations do
    profile_associations_json.each_value do |v|
      v.each do |obj|
        profile_associations_load(obj, obj['masterProfileType'], obj['detailProfileType'])
      end
    end
  end
end
