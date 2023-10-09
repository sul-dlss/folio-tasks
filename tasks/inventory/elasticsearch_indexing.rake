# frozen_string_literal: true

namespace :inventory do
  desc 'recreate search index (drops existing indices) with given resource name [instance, authority]'
  task :recreate_search_index, [:resource_name] do |_, args|
    FolioRequest.new.post('/search/index/inventory/reindex',
                          '{ "recreateIndex": "true", "resourceName": "'"#{args[:resource_name]}"'",
                             "indexSettings": { "numberOfReplicas": 0, "refreshInterval": 120 } }')
  end

  desc 'reindex search index with given resource name [instance, authority]'
  task :reindex_search, [:resource_name] do |_, args|
    FolioRequest.new.post('/search/index/inventory/reindex',
                          '{ "resourceName": "'"#{args[:resource_name]}"'" }')
  end

  desc 'monitor instances published to Kafka for reindex with given job id'
  task :search_index_job_status, [:job_id] do |_, args|
    FolioRequest.new.get("/instance-storage/reindex/#{args[:job_id]}")
  end

  desc 'update index dynamic settings to optimize full reindex with given resource name [instance, authority]'
  task :optimize_index_settings, [:resource_name] do |_, args|
    FolioRequest.new.put('/search/index/settings',
                         '{ "resourceName": "'"#{args[:resource_name]}"'",
                            "indexSettings": { "numberOfReplicas": 0, "refreshInterval": -1 } }')
  end

  desc 'update index dynamic settings to defaults (2 replicas) with given resource name [instance, authority]'
  task :default_index_settings, [:resource_name] do |_, args|
    FolioRequest.new.put('/search/index/settings',
                         '{ "resourceName": "'"#{args[:resource_name]}"'",
                            "indexSettings": { "numberOfReplicas": 2, "refreshInterval": 1 } }')
  end
end
