# frozen_string_literal: true

require_relative '../../lib/folio_request'

# Module to encapsulate folio request method
module FolioRequestHelper
  @@folio_request = FolioRequest.new

  def trim_hash(hash, name)
    hash[name].each do |obj|
      obj.delete('metadata')
      obj.delete('childOf')
      obj.delete('grantedTo')
      obj.delete('dummy')
      obj.delete('deprecated')
    end
    hash.delete('totalRecords')
    hash.delete('resultInfo')
    hash
  end
end
