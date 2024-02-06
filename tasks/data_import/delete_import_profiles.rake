# frozen_string_literal: true

require_relative '../helpers/data_import'

namespace :data_import do
  include DataImportTaskHelpers

  desc 'delete job profiles from folio'
  task :delete_job_profiles do
    hash = JSON.parse(pull_job_profiles)
    hash.each_value do |v|
      v.each do |obj|
        response = job_profiles_delete(obj['id'])
        puts response
      end
    end
  end

  desc 'delete action profiles from folio'
  task :delete_action_profiles do
    hash = JSON.parse(pull_action_profiles)
    hash.each_value do |v|
      v.each do |obj|
        response = action_profiles_delete(obj['id'])
        puts response
      end
    end
  end

  desc 'delete mapping profiles from folio'
  task :delete_mapping_profiles do
    hash = JSON.parse(pull_mapping_profiles)
    hash.each_value do |v|
      v.each do |obj|
        response = mapping_profiles_delete(obj['id'])
        puts response
      end
    end
  end

  desc 'delete match profiles from folio'
  task :delete_match_profiles do
    hash = JSON.parse(pull_match_profiles)
    hash.each_value do |v|
      v.each do |obj|
        response = match_profiles_delete(obj['id'])
        puts response
      end
    end
  end
end