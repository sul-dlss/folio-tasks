# frozen_string_literal: true

namespace :inventory do
  desc 'recreate resource index (drops index): [authority, location]'
  task :recreate_resource_index, [:resource_name] do |_, args|
    FolioRequest.new.post('/search/index/inventory/reindex',
                          '{ "recreateIndex": "true",
                             "resourceName": "' + args[:resource_name].to_s + '"
                            }')
  end

  desc 'recreate instances index (build new data model)'
  task :recreate_instances_index do
    FolioRequest.new.post_no_body('/search/index/instance-records/reindex/full')
  end

  desc 'reindex index for resource: [authority, location]'
  task :reindex_resource_index, [:resource_name] do |_, args|
    FolioRequest.new.post('/search/index/inventory/reindex',
                          '{ "recreateIndex": "false",
                             "resourceName": "' + args[:resource_name].to_s + '"
                            }')
  end

  desc 'reindex instances index'
  task :reindex_instances_index do
    FolioRequest.new.post('/search/index/instance-records/reindex/upload',
                          '{ "entityTypes": ["instance"]
                           }')
  end

  desc 'reindex subject index'
  task :reindex_subject_index do
    FolioRequest.new.post('/search/index/instance-records/reindex/upload',
                          '{ "entityTypes": ["subject"]
                           }')
  end

  desc 'reindex contributor index'
  task :reindex_contributor_index do
    FolioRequest.new.post('/search/index/instance-records/reindex/upload',
                          '{ "entityTypes": ["contributor"]
                           }')
  end

  desc 'reindex classification index'
  task :reindex_classification_index do
    FolioRequest.new.post('/search/index/instance-records/reindex/upload',
                          '{ "entityTypes": ["classification"]
                           }')
  end

  desc 'reindex call-number index'
  task :reindex_callnumber_index do
    FolioRequest.new.post('/search/index/instance-records/reindex/upload',
                          '{ "entityTypes": ["call-number"]
                           }')
  end

  desc 'reindex all entity type indexes'
  task :reindex_all_indexes do
    FolioRequest.new.post('/search/index/instance-records/reindex/upload',
                          '{ "entityTypes": ["instance", "subject", "contributor", "classification", "call-number"]
                           }')
  end

  desc 'monitor status for resource reindexing'
  task :search_index_job_status do
    FolioRequest.new.get('/search/index/instance-records/reindex/status')
  end

  desc 'reindex failed merge ranges'
  task :reindex_failed_merge do
    FolioRequest.new.post_no_body('/search/index/instance-records/reindex/merge/failed')
  end
end
