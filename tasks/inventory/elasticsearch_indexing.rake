# frozen_string_literal: true

namespace :inventory do
  desc 'recreate search index from scratch'
  task :recreate_search_index do
    FolioRequest.new.post('/search/index/inventory/reindex', '{ "recreateIndex": "true" }')
  end

  desc 'reindex search'
  task :reindex_search do
    FolioRequest.new.post_no_body('/search/index/inventory/reindex')
  end

  desc 'monitor a search reindex job with given id'
  task :search_index_job_status, [:job_id] do |_, args|
    FolioRequest.new.get("/instance-storage/reindex/#{args[:job_id]}")
  end
end
