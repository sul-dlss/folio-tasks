# frozen_string_literal: true

require_relative 'helpers/search'

namespace :search do
  include SearchTaskHelpers

  desc 'recreate resource index (drops index): [authority, location, linked-data-instance|work|hub]'
  task :recreate_resource_index, [:resource_name] do |_, args|
    obj = resource_reindex_hash(recreate: true, resource_name: args[:resource_name].to_s)
    reindex(resource_path, obj)
  end

  desc 'reindex index for resource: [authority, location, linked-data-instance|work|hub]'
  task :reindex_resource_index, [:resource_name] do |_, args|
    obj = resource_reindex_hash(recreate: false, resource_name: args[:resource_name].to_s)
    reindex(resource_path, obj)
  end

  desc 'recreate instances index (build new data model)'
  task :recreate_instances_index do
    reindex(instance_path)
  end

  desc 'upload entity index: [instance, subject, contributor, classification, call-number]'
  task :upload_index, [:entity_type] do |_, args|
    obj = { 'entityTypes' => [args[:entity_type].to_s] }
    reindex(upload_index_path, obj)
  end

  desc 'upload all entity type indexes (instance, subject, contributor, classification, call-number)'
  task :upload_all_indexes do
    obj = { 'entityTypes' => %w[instance subject contributor classification call-number] }
    reindex(upload_index_path, obj)
  end

  desc 'monitor status for resource reindexing'
  task :reindex_status do
    reindex_status
  end

  desc 'reindex failed merge ranges'
  task :reindex_failed_merge do
    reindex(failed_merge_path)
  end
end
