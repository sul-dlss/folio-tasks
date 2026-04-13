# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by search rake task
module SearchTaskHelpers
  include FolioRequestHelper

  def resource_reindex_hash(recreate: :recreate, resource_name: :resource_name)
    {
      'recreateIndex' => recreate,
      'resourceName' => resource_name
    }
  end

  def reindex(path, obj = nil)
    @@folio_request.post(path, obj)
  end

  def reindex_status
    @@folio_request.get('/search/index/instance-records/reindex/status')
  end

  def resource_path
    '/search/index/inventory/reindex'
  end

  def instance_path
    '/search/index/instance-records/reindex/full'
  end

  def upload_index_path
    '/search/index/instance-records/reindex/upload'
  end

  def failed_merge_path
    '/search/index/instance-records/reindex/merge/failed'
  end
end
